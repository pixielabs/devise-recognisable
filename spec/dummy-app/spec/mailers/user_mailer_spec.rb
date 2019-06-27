require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { FactoryBot.build :user }

  describe '#new_ip' do
    it 'works' do
      email = UserMailer.with(user: user).new_ip

      expect {
        email.deliver_now
      }.to change {
        ActionMailer::Base.deliveries.size
      }.by(1)
    end
  end

end
