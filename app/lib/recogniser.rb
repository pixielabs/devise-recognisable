class Recogniser
  @@required_scores = {
    relaxed: 0,
    normal: 1,
    strict: 2
  }

  # Checks the current request against the details from the previous sign in.
  def self.recognise?(request, previous_session)
    score = 0

    # Is the user's IP different to the last one?
    # Is it more than a certain distance from the last successful sign in?
    #
    # NOTE: Geocoder's location method might not be the safest?
    # See https://github.com/alexreisner/geocoder#geocoding-http-requests
    last_sign_in = Geocoder.search(previous_session.sign_in_ip).first
    current_sign_in = Geocoder.search(request.location.ip).first
    # NOTE: looks like sometimes the current_sign_in isn't a real thing?
    distance = Geocoder::Calculations.distance_between(last_sign_in&.coordinates, current_sign_in&.coordinates)
    if previous_session.sign_in_ip == request.location.ip or distance < Devise.max_ip_distance
      score += 1
    end

    # Is the user's User Agent is different to the previous signin?
    score += 1 if previous_session.user_agent == request.user_agent

    # Is the user's Accept header is different to the previous signin?
    score += 1 if previous_session.accept_header == request.headers["HTTP_ACCEPT"]

    score > @@required_scores[Devise.security_level]
  end
end