# A Debug class that performs exaclty like the Guard class but also logs the
# a result with the highest match score when a recognition fails. 
# This code only runs if `Devise.debug_logs` is set to true in the config.
class DebugGuard
  @@required_scores = {
    relaxed: 0,
    normal: 1,
    strict: 2
  }

  # Checks the current request against details from previous sign ins.
  # If the requester is not recognised and app is running in a Production env,
  # the values for the request and the closest matching RecognisableSession are
  # logged to `recognise_logs.txt`.
  def self.recognise?(request, previous_sessions)
    results = previous_sessions.map do |session|
      calculate_score_for_session(request, session)
    end

    max_result = results.max{ |a, b| a[:score] <=> b[:score] }
    if max_result[:score] > @@required_scores[Devise.security_level]
      return true
    else
      if Rails.env.production?
        File.write("recognise_logs.txt", JSON.pretty_generate(max_result), mode: "a")
      end
      return false
    end
  end

  # Calculates the request's score against an individual RecognisableSession.
  # Returns a results object that contains the relevant information on 
  # which conditions failed.
  def self.calculate_score_for_session(request, session)
    result = {
      request_id: request.request_id,
      user_id: session.recognisable_id,
      user_type: session.recognisable_type,
      score: 0,
      failures: {},
      time: Time.now
    }

    # Is the user's IP different to the last one?
    # Is it more than a certain distance from the last successful sign in?
    if Guard.compare_ip_addresses(request.location.ip, session.sign_in_ip)
      result[:score] += 1
    else
      result[:failures][:ip_address] = {
        request_value: request.location.ip,
        session_value: session.sign_in_ip
      }
    end

    # Is the user's User Agent is different to the previous sign in?
    if session.user_agent == request.user_agent
      result[:score] += 1
    else
      result[:failures][:user_agent] = {
        request_value: request.user_agent,
        session_value: session.user_agent
      }
    end

    # Is the user's Accept header is different to the previous sign in?
    if session.accept_header == request.headers["HTTP_ACCEPT"]
      result[:score] += 1
    else
      result[:failures][:accept_header] = {
        request_value: request.headers["HTTP_ACCEPT"],
        session_value: session.accept_header
      }
    end

    return result
  end
end