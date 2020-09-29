class Recogniser
  # Checks 
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

    # Is the user's User Agent different to the last one?
    if previous_session.user_agent == request.user_agent
      score += 1
    end

    score > 1
  end
end