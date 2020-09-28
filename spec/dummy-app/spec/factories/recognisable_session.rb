FactoryBot.define do
  factory(:recognisable_session, :class => DeviseRecognisable::RecognisableSession) do
    user
    sign_in_ip { FFaker::Internet.ip_v4_address }
    sign_in_at { Time.now - 1.hour }
  end
end

