# A Class that is responsible for recognising a request by comparing the request
# to previous sign ins.
class Recogniser
  @@required_scores = {
    relaxed: 0,
    normal: 1,
    strict: 2
  }

  def self.with(request)
    self.new(request)
  end

  def initialize(request)
    @request = request
  end

  # Checks the current request against details from previous sign ins.
  def recognise?(previous_sessions)
    previous_sessions.any? do |session|
      calculate_score_for(session) > @@required_scores[Devise.security_level]
    end
  end

  # Calculates the request's score against an individual RecognisableSession.
  def calculate_score_for(session)
    score = 0

    # Is the user's IP different to the last one?
    # Is it more than a certain distance from the last successful sign in?
    #
    # NOTE: Geocoder's location method might not be the safest?
    # See https://github.com/alexreisner/geocoder#geocoding-http-requests
    last_sign_in = Geocoder.search(session.sign_in_ip).first
    current_sign_in = Geocoder.search(@request.location.ip).first
    # NOTE: looks like sometimes the current_sign_in isn't a real thing?
    distance = Geocoder::Calculations.distance_between(last_sign_in&.coordinates, current_sign_in&.coordinates)
    if session.sign_in_ip == @request.location.ip or distance < Devise.max_ip_distance
      score += 1
    end

    # Is the user's User Agent is different to the previous sign in?
    score += 1 if session.user_agent == @request.user_agent

    # Is the user's Accept header is different to the previous sign in?
    score += 1 if session.accept_header == @request.headers["HTTP_ACCEPT"]

    return score
  end
end