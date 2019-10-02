require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { FFaker::Internet.email }
  let(:password) { FFaker::Internet.password }

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
  end

  context 'from a different IP' do
    # Create a user with FactoryBot so the ip will be different.
    let!(:user) { FactoryBot.create :user }

    before do
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

      it 'works' do
        # Visiting the link in the email logs the user in
        open_email(user.email, with_subject: I18n.t('devise.mailer.new_ip.subject'))
        visit_in_email('Log in')
        expect(page).to have_content('Home sweet home')
      end

    end
  end
end
