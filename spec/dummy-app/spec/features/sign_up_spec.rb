require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  context 'as a new user' do
    it 'creates a devise recognisable session' do
      visit '/'
      expect(page).to have_content 'Welcome to my website'
      click_link 'Log in'
      click_link 'Sign up'
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      expect {
        click_button 'Sign up'
      }.to change(DeviseRecognisable::RecognisableSession, :count).by(1)
      expect(page).to have_content 'Welcome!'
      expect(page).to have_content('signed up successfully')
    end
  end
end
