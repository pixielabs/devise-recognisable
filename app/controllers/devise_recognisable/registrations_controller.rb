
class DeviseRecognisable::RegistrationsController < Devise::RegistrationsController
  append_after_action :store_recognisable_details, only: :create

  # After the user has been signed up, we save the ip address in the
  # DeviseRecognisable::RecognisableSession table.
  def store_recognisable_details
    return unless resource.persisted?
    DeviseRecognisable::RecognisableSession.create!(
      recognisable: resource_class.find_by(email: params[resource_name][:email]),
      sign_in_ip: request.location.ip,
      sign_in_at: Time.now,
      user_agent: request.user_agent,
      accept_header: request.headers["HTTP_ACCEPT"]
    )
  end
end
