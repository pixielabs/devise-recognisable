require 'geocoder'

class DeviseRecognisable::SessionsController < Devise::SessionsController
  prepend_before_action :check_for_authentication_token, only: :new
  prepend_before_action :perform_ip_check, only: :create
  append_after_action :store_recognisable_details, only: :create
 
  def perform_ip_check
    # Find the user
    self.resource = resource_class.find_by(email: params[resource_name][:email])
    previous_session = Devise.ref('DeviseRecognisable::RecognisableSession').get
      .where( recognisable: self.resource ).last

    return unless self.resource && previous_session.present?

    # Is the user's IP different to the last one?
    # Is it more than a certain distance from the last successful sign in?
    #
    # NOTE: Geocoder's location method might not be the safest?
    # See https://github.com/alexreisner/geocoder#geocoding-http-requests
    last_sign_in = Geocoder.search(previous_session.sign_in_ip).first
    current_sign_in = Geocoder.search(request.location.ip).first
    # NOTE: looks like sometimes the current_sign_in isn't a real thing?
    distance = Geocoder::Calculations.distance_between(last_sign_in&.coordinates, current_sign_in&.coordinates)

    if previous_session.sign_in_ip != request.location.ip or distance > Devise.max_ip_distance
      # Don't sign the user in, return them to the sign in screen with a flash
      # message.
      set_flash_message(:alert, :send_new_ip_instructions)
      redirect_to new_session_path(resource_class)

      # Send an email to the user with a sign in link containing a unique
      # token that is valid for 5 minutes.
      resource_class.send_new_ip_email(resource_params)
    end
  end

  # Check whether the user is attempting to sign in from a link in an email.
  def check_for_authentication_token
    if params[:token].present?
      token = AuthenticationToken.decode(params[:token])

      # Check the token hasn't expired.
      return new_session_path(resource_class) if token[:exp] < Time.now.to_i

      self.resource = resource_class.find token['id']

      sign_in self.resource
    end
  end

  # After the user has been signed in, we save the ip address in the
  # DeviseRecognisable::RecognisableSession table.
  def store_recognisable_details
    DeviseRecognisable::RecognisableSession.create!(
      recognisable: resource_class.find_by(email: params[resource_name][:email]),
      sign_in_ip: request.location.ip,
      sign_in_at: Time.now
    )
  end
end
