# A Class that is responsible for recognising a request by comparing the request
# to previous sign ins.
class DeviseRecognisable::Guard
  @@required_scores = {
    relaxed: 0,
    normal: 1,
    strict: 2
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
    score += 1 if compare_ip_addresses(session.sign_in_ip)

    # Is the request's User Agent different to the session's sign in?
    score += 1 if session.user_agent == @request.user_agent

    # Is the request's Accept header different to the previous sign in?
    score += 1 if session.accept_header == @request.headers["HTTP_ACCEPT"]

    return score
  end

  # Method to check if the ip addresses are similar. Takes a session_address
  # and returns a bool
  def compare_ip_addresses(session_address)
    return true if session_address == @request.location.ip
    
    # NOTE: Geocoder's location method might not be the safest?
    # See https://github.com/alexreisner/geocoder#geocoding-http-requests
    previous_sign_in = Geocoder.search(session_address).first
    current_sign_in = Geocoder.search(@request.location.ip).first
    
    # NOTE: looks like sometimes the current_sign_in isn't a real thing?
    distance = Geocoder::Calculations.distance_between(previous_sign_in&.coordinates, current_sign_in&.coordinates)
    
    distance < Devise.max_ip_distance
  end

  # Debug mode only: Returns a results object that contains the relevant
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
    unless compare_ip_addresses(@closest_match[:session].sign_in_ip)
      failures[:failures][:ip_address] = {
        request_value: @request.location.ip,
        session_value: @closest_match[:session].sign_in_ip
      }
    end

    # Is the request's User Agent different to the session's sign in?
    unless @closest_match[:session].user_agent == @request.user_agent
      failures[:failures][:user_agent] = {
        request_value: @request.user_agent,
        session_value: @closest_match[:session].user_agent
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

end