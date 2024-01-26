require 'geocoder'

class DeviseRecognisable::SessionsController < Devise::SessionsController
  append_before_action :check_for_authentication_token, only: :new
  prepend_before_action :perform_recognition_check, only: :create
  append_after_action :store_recognisable_details, only: :create

  def perform_recognition_check
    # Find the user
    self.resource = resource_class.find_by(email: params[resource_name][:email])
    return unless self.resource

    previous_sessions = DeviseRecognisable::RecognisableSession
      .where( recognisable: self.resource )
    return if previous_sessions.none?

    guard = DeviseRecognisable::Guard.with(previous_sessions)

    unless guard.recognise?(request)
      # Skip if running in info_only mode
      unless Devise.info_only
        # Don't sign the user in, return them to the sign in screen with a flash
        # message.
        set_flash_message(:alert, :send_new_ip_instructions)
        redirect_to new_session_path(resource_class)

        # Send an email to the user with a sign in link containing a unique
        # token that is valid for 5 minutes.
        resource_class.send_new_ip_email(resource_params)
      end

      # debug or info_only mode
      # If there is no error_logger set up, we don't even want to attempt to send a message
      return unless Devise.error_logger

      if (Devise.debug_mode || Devise.info_only) && (Rails.env.production? || Rails.env.staging?)
        Devise.error_logger.call(guard.failures, 'Unrecognised request')
      end
    end
  end

  # Check whether the user is attempting to sign in from a link in an email.
  def check_for_authentication_token
    return unless params[:token].present?

    token = AuthenticationToken.decode(params[:token])

    # Check the token hasn't expired.
    return new_session_path(resource_class) if token[:exp] < Time.now.to_i

    self.resource = resource_class.find token['id']

    sign_in self.resource
    DeviseRecognisable::RecognisableSession.create!(
      recognisable: resource_class.find_by(email: self.resource.email),
      sign_in_ip: request.location.ip,
      sign_in_at: Time.now,
      user_agent: request.user_agent,
      accept_header: request.headers["HTTP_ACCEPT"],
      accept_language: request.headers["Accept-Language"]
    )
    redirect_to after_sign_in_path_for(resource)
  end

  # After the user has been signed in, we save the ip address in the
  # DeviseRecognisable::RecognisableSession table.
  def store_recognisable_details
    DeviseRecognisable::RecognisableSession.create!(
      recognisable: resource_class.find_by(email: params[resource_name][:email]),
      sign_in_ip: request.location.ip,
      sign_in_at: Time.now,
      user_agent: request.user_agent,
      accept_header: request.headers["HTTP_ACCEPT"],
      accept_language: request.headers["Accept-Language"]
    )
  end
end
