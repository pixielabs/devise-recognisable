require 'damerau-levenshtein'

# A Class that is responsible for recognising a request by comparing the request
# to previous sign ins.
class DeviseRecognisable::Guard
  # NOTE: I've set this to 0 for now so we can observe the Levenshtein distances
  # in debug_mode. We can set it to an appropriate value when we have more data.
  MAX_LEVENSHTEIN_DISTANCE = Rails.env.test? ? 10 : 0

  @@required_scores = {
    relaxed: 2,
    normal: 3,
    strict: 4
  }

  def self.with(previous_sessions)
    self.new(previous_sessions)
  end

  def initialize(previous_sessions)
    @previous_sessions = previous_sessions
    @closest_match = nil
  end

  # Checks the current request against details from previous sign ins.
  def recognise?(request)
    @request = request
    @previous_sessions.each do |session|
      score = calculate_score_for session

      # If the session matches the request, the method returns true.
      return true if score > @@required_scores[Devise.security_level]

      # If the session does not match the request but does have a higher score
      # than the current closest_match, the closest_match is replaced with the
      # session.
      if @closest_match.nil? || @closest_match[:score] < score
        @closest_match = { session: session, score: score }
      end
    end

    # If none of the sessions match the request, the method returns false.
    return false
  end

  # Calculates the request's score against an individual RecognisableSession.
  def calculate_score_for(session)
    score = 0

    # Is the requests's IP different to the session's?
    # Is it more than a certain distance from the session's IP address?
    case compare_ip_addresses(session.sign_in_ip)
    when :exact_match then score += 3
    when :network_match then score += 2
    when :within_distance then score += 1
    end

    # Is the request's User Agent different to the session's sign in?
    score += 1 if compare_user_agents(session.user_agent)

    # Is the request's Accept header different to the previous sign in?
    score += 1 if session.accept_header == @request.headers["HTTP_ACCEPT"]

    return score
  end

  # Method to check if the ip addresses are similar. Takes a session_address
  # and returns a :symbol for the level of similarity.
  def compare_ip_addresses(session_address)
    # Check if the IP is an exact match
    return :exact_match if session_address == @request.location.ip

    # Check that neither IP address is IPv6.
    # If either is, return :complete_mismatch.
    if ipv6?(@request.location.ip) || ipv6?(session_address)
      return :complete_mismatch
    end

    # Check if the IP network octets match
    session_network = network_octets(session_address)
    request_network = network_octets(@request.location.ip)
    return :network_match if session_network == request_network

    # Check if the request IP is within the max_ip_distance from a previous IP
    # NOTE: Geocoder's location method might not be the safest?
    # See https://github.com/alexreisner/geocoder#geocoding-http-requests
    begin
      previous_sign_in = Geocoder.search(session_address).first
      current_sign_in = Geocoder.search(@request.location.ip).first
      # NOTE: looks like sometimes the current_sign_in isn't a real thing?
    rescue => e
      if (Devise.debug_mode || Devise.info_only) && Devise.error_logger
        # Send information about a failed request to error_logger
        Devise.error_logger.call(e, 'A request to Geocoder failed.')
      end
    else
      distance = Geocoder::Calculations.distance_between(previous_sign_in&.coordinates, current_sign_in&.coordinates)
      return :within_distance if distance < Devise.max_ip_distance
    end

    # If the request IP does not pass any of the comparisons,
    return :complete_mismatch
  end

  # Method to check if the user agent strings are similar. Uses the Levenshtein
  # distance to calculate the minumum number of changes required to make an
  # exact match. Takes a session user agent string and returns a bool.
  def compare_user_agents(session_user_agent)
    return true if session_user_agent == @request.user_agent

    # DamerauLevenshtein.distance() takes two strings and an optional
    # argument. The optional argument specifies which algorithm should
    # be used to calculate the distance between the two strings.
    # Here we pass in 0 to use the Levenshtein distance.
    distance = DamerauLevenshtein.distance(@request.user_agent, session_user_agent, 0)

    distance < MAX_LEVENSHTEIN_DISTANCE
  end

  # debug or info_only modes: Returns a results object that contains the relevant
  # information on which conditions failed.
  def failures
    failures = {
      request_id: @request.request_id,
      user_id: @closest_match[:session].recognisable_id,
      user_type: @closest_match[:session].recognisable_type,
      score: @closest_match[:score],
      failures: {},
      time: Time.now
    }

    # Is the requests's IP different to the session's?
    # Is it more than a certain distance from the session's IP address?
    ip_comparison_result = compare_ip_addresses(@closest_match[:session].sign_in_ip)
    unless ip_comparison_result == :exact_match
      failures[:failures][:ip_address] = {
        request_value: @request.location.ip,
        session_value: @closest_match[:session].sign_in_ip,
        comparison_result: ip_comparison_result
      }
    end

    # Is the request's User Agent different to the session's sign in?
    unless compare_user_agents(@closest_match[:session].user_agent)
      failures[:failures][:user_agent] = {
        request_value: @request.user_agent,
        session_value: @closest_match[:session].user_agent,
        # DamerauLevenshtein.distance() takes two strings and an optional
        # argument. The optional argument specifies which algorithm should
        # be used to calculate the distance between the two strings.
        # Here we pass in 0 to use the Levenshtein distance.
        levenshtein_distance: DamerauLevenshtein.distance(
          @request.user_agent,
          @closest_match[:session].session_user_agent,
          0
        )
      }
    end

    # Is the request's Accept header different to the previous sign in?
    unless @closest_match[:session].accept_header == @request.headers["HTTP_ACCEPT"]
      failures[:failures][:accept_header] = {
        request_value: @request.headers["HTTP_ACCEPT"],
        session_value: @closest_match[:session].accept_header
      }
    end

    return failures
  end

  private

  # Extract the Network octets from an IP. Takes an IP address and returns
  # an array of the octets. The network octets vary in number between different
  # IP classes. You can determine the class by looking at the value of the
  # left most octet.
  # http://penta2.ufrgs.br/trouble/ts_ip.htm#First-Octet%20Rule
  CLASS_A_UPPER_LIMIT = 126
  CLASS_B_UPPER_LIMIT = 191
  def network_octets(ip_address)
    octets = ip_address.split('.')

    left_most_octet = octets[0].to_i
    if left_most_octet <= CLASS_A_UPPER_LIMIT
      network_octets = [octets[0]]
    elsif left_most_octet <= CLASS_B_UPPER_LIMIT
      network_octets = octets[0..1]
    else
      network_octets = octets[0..2]
    end
  end

  def ipv6?(ip_address)
    ip_address.include? ':'
  end
end
