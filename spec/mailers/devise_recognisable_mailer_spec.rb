require "rails_helper"

RSpec.describe Devise::Mailer, type: :mailer do
  let(:user) { FactoryBot.build :user }

  describe '#new_ip' do
    it 'works' do
      email = Devise::Mailer.new_ip(user, 'token', {})

      expect {
        email.deliver_now
      }.to change {
        ActionMailer::Base.deliveries.size
      }.by(1)
    end
  end

end
