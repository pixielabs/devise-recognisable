require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { FFaker::Internet.email }
  let(:password) { FFaker::Internet.password }

  context 'as a user that has no last_sign_in_ip' do
    let!(:user) { FactoryBot.create :user }

    it 'works and does not send an email' do
      visit '/'
      expect(page).to have_content 'Welcome to my website'
      click_link 'Log in'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(page).to have_content 'Home sweet home'
      expect(page).to have_content('Signed in successfully')
    end
  end

  context 'with the same IP' do
    before do
      # Create a user to sign in so that it's the same ip.
      visit '/'
      click_link 'Log in'
      click_link 'Sign up'
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_button 'Sign up'
      click_link 'Log out'
    end

    it 'works' do
      visit '/'
      expect(page).to have_content 'Welcome to my website'
      click_link 'Log in'
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Log in'
      expect(page).to have_content 'Home sweet home'
    end

    it 'creates a new DeviseRecognisable::RecognisableSession on successful sign in' do
      expect {
        visit '/'
        click_link 'Log in'
        fill_in 'Email', with: email
        fill_in 'Password', with: password
        click_button 'Log in'
      }.to change { DeviseRecognisable::RecognisableSession.count }.from(0).to(1)
    end

    it "doesn't create a new DeviseRecognisable::RecognisableSession on unsuccessful sign in" do
      expect {
        visit '/'
        click_link 'Log in'
        fill_in 'Email', with: email
        fill_in 'Password', with: FFaker::Internet.password
        click_button 'Log in'
      }.not_to change { DeviseRecognisable::RecognisableSession.count }
    end
  end

  context 'from a different IP' do
    let!(:user) { FactoryBot.create :user }
    let!(:recognisable_session) { FactoryBot.create :recognisable_session, recognisable_id: user.id, recognisable_type: 'User' }

    before do
      recognisable_session.update(sign_in_ip: FFaker::Internet.ip_v4_address)
      visit '/'
      click_link 'Log in'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end

    it 'does not log the user in' do
      expect(page).to have_content I18n.t('devise.sessions.send_new_ip_instructions')
      expect(page).to_not have_content('Home sweet home')
    end

    context 'visiting the link in the email' do
      it 'logs the user in' do
        open_email(user.email, with_subject: I18n.t('devise.mailer.new_ip.subject'))
        visit_in_email('Log in')
        expect(page).to have_content('Home sweet home')
      end

      it 'creates a new DeviseRecognisable::RecognisableSession on sucessfull sign in' do
        expect {
          open_email(user.email, with_subject: I18n.t('devise.mailer.new_ip.subject'))
          visit_in_email('Log in')
        }.to change { DeviseRecognisable::RecognisableSession.count }.from(1).to(2)
      end
    end
  end
end
