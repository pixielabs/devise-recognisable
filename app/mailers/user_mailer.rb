class UserMailer < ApplicationMailer

  def new_ip
    @user = params[:user]
    @url_token = AuthenticationToken.encode(user_id: @user.id)
    mail(to: @user.email, subject: I18n.t('devise.mailer.new_ip'))
  end
end
