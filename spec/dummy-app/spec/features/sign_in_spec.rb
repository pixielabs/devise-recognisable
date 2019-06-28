require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { FFaker::Internet.email }
  let(:password) { FFaker::Internet.password }

  before do
    visit '/'
    click_link 'Log in'
    click_link 'Sign up'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    click_button 'Sign up'
    click_link 'Log out'
  end

  it 'works with the same IP' do
    visit '/'
    expect(page).to have_content 'Welcome to my website'
    click_link 'Log in'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Log in'
    expect(page).to have_content 'Home sweet home'
  end

  context 'from a different IP' do
    let!(:user) { FactoryBot.create :user }

    it 'does not log the user in' do
        visit '/'
        click_link 'Log in'
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'
        expect(page).to have_content I18n.t('devise.sessions.user.new_ip')
        open_email(user.email, with_subject: I18n.t('devise.mailer.new_ip.subject'))
        visit_in_email('Log in')
        expect(page).to have_content('Home sweet home')
    end
  end
end
