require 'rails_helper'

RSpec.feature "Sign in" do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }
  let!(:user) { FactoryBot.create :user }

  let!(:user_agent) { 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36' }
  let!(:accept_header) { 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' }
  let!(:recognisable_session_values) {{
    recognisable_id: user.id,
    recognisable_type: 'User',
    user_agent: user_agent,
    accept_header: accept_header
  }}

  before do
    Capybara.current_session.driver.header('User-Agent', user_agent)
    Capybara.current_session.driver.header('Accept', accept_header)
  end

  context 'as a user that has no last_sign_in_ip' do
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
      click_button 'Log out'
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
        fill_in 'Password', with: Faker::Internet.password
        click_button 'Log in'
      }.not_to change { DeviseRecognisable::RecognisableSession.count }
    end
  end

  context 'from a different IP' do
    let!(:recognisable_session) { FactoryBot.create :recognisable_session, recognisable_session_values }
    #  In order to send debug messages, we will need to set up Devise.error_logger with the error
    # monitoring tool of our choice, we have chosen Rollbar for tests
    let!(:send_debug_message) { lambda { |info, error_message| Rollbar.debug(info, error_message) } }

    context 'with Devise.debug_mode set to false' do
      context 'if the ip addresses are of the same IP version' do
        before do
          recognisable_session.update(sign_in_ip: Faker::Internet.ip_v4_address)
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
            expect(page).to_not have_content 'You are already signed in'
          end

          it 'creates a new DeviseRecognisable::RecognisableSession on sucessfull sign in' do
            expect {
              open_email(user.email, with_subject: I18n.t('devise.mailer.new_ip.subject'))
              visit_in_email('Log in')
            }.to change { DeviseRecognisable::RecognisableSession.count }.from(1).to(2)
          end
        end
      end

      context 'if the ip addresses are of different IP versions' do
        before do
          recognisable_session.update(sign_in_ip: Faker::Internet.ip_v6_address)
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

    context 'with Devise.debug_mode set to true' do
      let!(:new_ip) { Faker::Internet.ip_v4_address }
      before do
        allow(Devise).to receive(:debug_mode).and_return(true)
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
        allow(Rails).to receive_message_chain(:env, :development?).and_return(false)
        recognisable_session.update(sign_in_ip: new_ip)
      end

      context 'if there is a Devise.error_logger' do
        before do
          allow(Devise).to receive(:error_logger).and_return(send_debug_message)
        end

        it 'Rollbar will recieve an error message' do
          expect(Rollbar).to receive(:debug)
            .with(hash_including(
              :failures=> {:ip_address=>{
                :request_value=>"127.0.0.1",
                :session_value=>new_ip,
                :comparison_result=>:complete_mismatch
              }},
              :score=>2,
              :user_id=>1,
              :user_type=>"User"
              ), "Unrecognised request")
          visit '/'
          click_link 'Log in'
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Log in'
        end
      end

      it 'Rollbar will not receive an error message if there is no Devise.error_logger' do
        expect(Rollbar).to receive(:debug).never
        visit '/'
        click_link 'Log in'
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'
      end
    end

    context 'with Devise.info_only set to true' do
      let!(:new_ip) { Faker::Internet.ip_v4_address }
      before do
        allow(Devise).to receive(:info_only).and_return(true)
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
        allow(Rails).to receive_message_chain(:env, :development?).and_return(false)
        recognisable_session.update(sign_in_ip: new_ip)
      end

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

      context 'if there is a Devise.error_logger' do
        before do
          allow(Devise).to receive(:error_logger).and_return(send_debug_message)
        end

        it 'a debug message is sent to Rollbar' do
          expect(Rollbar).to receive(:debug)
            .with(hash_including(
              :failures=> {:ip_address=>{
                :request_value=>"127.0.0.1",
                :session_value=>new_ip,
                :comparison_result=>:complete_mismatch
              }},
              :score=>2,
              :user_id=>1,
              :user_type=>"User"
              ), "Unrecognised request")
          visit '/'
          click_link 'Log in'
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Log in'
        end
      end

      it 'will not send a debug message if there is no Devise.error_logger' do
        expect(Rollbar).to receive(:debug).never
        visit '/'
        click_link 'Log in'
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'
      end
    end
  end

  context 'from a device with a different User Agent' do
    let!(:recognisable_session) { FactoryBot.create :recognisable_session, recognisable_session_values }
    let!(:new_user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko)' }

    before do
      recognisable_session.update!(user_agent: new_user_agent)
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
    end
  end

  context 'from a device with User Agent that is only slightly different' do
    let!(:recognisable_session) { FactoryBot.create :recognisable_session, recognisable_session_values }
    # Change the Chrome build number by one
    let!(:new_user_agent) { user_agent.gsub(/78.0.3904.108/, '78.0.3904.109') }

    before do
      recognisable_session.update!(user_agent: new_user_agent)
      visit '/'
      click_link 'Log in'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end

    it 'logs the user in' do
      expect(page).to have_content 'Home sweet home'
      expect(page).to have_content('Signed in successfully')
    end
  end

  context 'from a device with a different Accept header value' do
    let!(:recognisable_session) { FactoryBot.create :recognisable_session, recognisable_session_values }
    let!(:new_accept_header) { 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' }

    before do
      recognisable_session.update!(accept_header: new_accept_header)
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
    end
  end

  context 'with multiple different RecognisableSessions' do
    let!(:different_user_agent) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko)' }
    let!(:different_accept_header) { 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' }
    let!(:different_recognisable_session_values) {{
      recognisable_id: user.id,
      recognisable_type: 'User',
      user_agent: different_user_agent,
      accept_header: different_accept_header
    }}

    before do
      # This creates a recognisable session.
      visit '/'
      click_link 'Log in'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      click_button 'Log out'

      # Create a recognisable session from a different device.
      FactoryBot.create :recognisable_session, different_recognisable_session_values
    end

    it 'can match a session other than the most recent and lets the user in' do
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
end
