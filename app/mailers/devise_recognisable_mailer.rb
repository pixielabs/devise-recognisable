class DeviseRecognisableMailer < Devise::Mailer

  def new_ip(record, token, opts={})
    @token = token
    devise_mail(record, :new_ip, opts)
  end

end
