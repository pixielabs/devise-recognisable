require "devise-recognisable"

FactoryBot.define do
  factory(:recognisable_session, :class => DeviseRecognisable::RecognisableSession) do
    sign_in_ip { "127.0.0.1" }
    sign_in_at { Time.now - 1.hour }
  end
end

