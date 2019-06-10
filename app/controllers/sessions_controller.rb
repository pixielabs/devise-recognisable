class SessionsController < Devise::SessionsController
  prepend_before_action :check_for_authentication_token, only: :new
  prepend_before_action :perform_ip_check, only: :create
  skip_before_action :require_no_authentication, only: :create

  MAX_DISTANCE = 100

  # Check that users aren't trying to sign in from a new location.
  # This is mainly pulling all the stuff from Devise's :require_no_authentication.
  # See https://github.com/plataformatec/devise/blob/715192a7709a4c02127afb067e66230061b82cf2/app/controllers/devise_controller.rb#L98
  def perform_ip_check
    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name

      # Find the user
      user = User.find_by(email: params[:user][:email])

      # Is the user's IP different to the last one?
      # Is it more than a certain distance from the last successful sign in?
      #
      # NOTE: Geocoder's location method might not be the safest?
      # See https://github.com/alexreisner/geocoder#geocoding-http-requests
      last_sign_in = Geocoder.search(user.last_sign_in_ip).first
      current_sign_in = Geocoder.search(request.location.ip).first
      # NOTE: looks like sometimes the current_sign_in isn't a real thing?
      distance = Geocoder::Calculations.distance_between(last_sign_in&.coordinates, current_sign_in&.coordinates)

      if user.last_sign_in_ip != request.location.ip or distance > MAX_DISTANCE

        # Don't sign the user in, return them to the sign in screen with a flash
        # message.
        set_flash_message(:alert, :new_ip)
        redirect_to new_user_session_path

        # Send an email to the user with a link containing a unique token that is
        # valid for 5 minutes.
        # When the user clicks the link, sign them in.
        UserMailer.with(user: user).new_ip.deliver_now
      else
        # It's the same IP, so sign them in!
        warden.authenticate?(*args)
      end
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to after_sign_in_path_for(resource)
    end
  end

  # Check whether the user is attempting to sign in from a link in an email.
  def check_for_authentication_token
    if params[:token].present?
      token = AuthenticationToken.decode(params[:token])

      # Check the token hasn't expired.
      return new_user_session_path if token[:exp] < Time.now.to_i

      user = User.find token['user_id']

      sign_in user
    end
  end

end
