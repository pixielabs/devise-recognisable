require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  let!(:user_agent) { 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36' }
  let!(:accept_header) { 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' }
  # let!(:recognisable_session_values) {{
  #   recognisable_id: user.id,
  #   recognisable_type: 'User',
  #   user_agent: user_agent,
  #   accept_header: accept_header
  # }}

  before do
    Capybara.current_session.driver.header('User-Agent', user_agent)
    Capybara.current_session.driver.header('Accept', accept_header)
  end

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
