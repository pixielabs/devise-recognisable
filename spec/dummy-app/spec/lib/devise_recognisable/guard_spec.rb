require 'rails_helper'
require 'geocoder'

RSpec.describe DeviseRecognisable::Guard do
  let(:mock_session) { double("MockPreviousSession", :sign_in_ip => "106.114.4.175") }
  let(:mock_request) { double("MockRequest", :location => mock_geocode_location) }
  let(:guard) { described_class.new([mock_session]) }
  
  context "#compare_ip_addresses" do
    before do
      # This is a little odd, but all we want to assign the mock_request to
      # Guard's @request.
      allow(guard).to receive(:calculate_score_for).and_return(0)
      guard.recognise?(mock_request)
    end

    context 'if the ip addresses are identical' do
      let(:mock_geocode_location) { double("MockGeocodeLocation", :ip => "106.114.4.175") }
      it 'returns :exact_match' do
        expect(guard.compare_ip_addresses(mock_session.sign_in_ip)).to eq :exact_match
      end
    end

    context 'if only the ip addresses host octets are different' do
      let(:mock_geocode_location) { double("MockGeocodeLocation", :ip => "106.114.77.88") }
      it 'returns :network_match' do
        expect(guard.compare_ip_addresses(mock_session.sign_in_ip)).to eq :network_match
      end
    end

    context 'if the ip addresses are within the configuarble distance of each other' do
      let(:mock_geocode_location) { double("MockGeocodeLocation", :ip => "200.200.200.200") }
      it 'returns :within_distance' do
        allow(Geocoder::Calculations).to receive(:distance_between)
          .and_return(Devise.max_ip_distance - 1)
        expect(guard.compare_ip_addresses(mock_session.sign_in_ip)).to eq :within_distance
      end
    end

    context 'if the ip addresses are completly different' do
      let(:mock_geocode_location) { double("MockGeocodeLocation", :ip => "40.100.100.100") }
      it 'returns :within_distance' do
        expect(guard.compare_ip_addresses(mock_session.sign_in_ip)).to eq :complete_mismatch
      end
    end
  end
end