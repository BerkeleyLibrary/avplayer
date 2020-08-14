require 'rails_helper'

require 'av/core'
require 'health/check'

module Health
  describe Check do
    attr_reader :wowza_uri, :millennium_uri, :tind_uri, :all_checks

    before(:each) do
      @wowza_uri = AV::Track.hls_uri_for(collection: Check::TEST_WOWZA_COLLECTION, relative_path: Check::TEST_WOWZA_PATH)

      @millennium_uri = AV::Metadata::Source::MILLENNIUM.marc_uri_for(Check::TEST_BIB_NUMBER)
      @tind_uri = AV::Metadata::Source::TIND.marc_uri_for(Check::TEST_TIND_ID)

      @all_checks = {
        Check::MILLENNIUM_CHECK => millennium_uri,
        Check::TIND_CHECK => tind_uri,
        Check::WOWZA_CHECK => wowza_uri
      }
    end

    describe 'success' do
      it 'returns PASS if all services are up' do
        all_checks.each_value do |service_uri|
          stub_request(:head, service_uri).to_return(status: 200)
        end

        check = Check.new
        aggregate_failures('check') do
          expect(check.http_status_code).to eq(200)

          check_json = check.as_json
          expect(check_json[:status]).to eq(Status::PASS)

          details = check_json[:details]
          all_checks.each_key do |c|
            expect(details[c]).to eq(Result.pass.as_json)
          end
        end
      end
    end

    describe 'failure' do
      invalid_states = {
        207 => '207', # We use status 207 as a proxy for "something weird RestClient thinks is not an error"
        500 => RestClient::InternalServerError.name
      }

      Check.all_checks.each_key do |c|
        invalid_states.each do |invalid_state, expected_details|
          it "returns WARN if #{c} returns #{invalid_state}" do
            passing_checks = (all_checks.keys - [c])

            passing_checks.each do |p|
              stub_request(:head, all_checks[p]).to_return(status: 200)
            end
            stub_request(:head, all_checks[c]).to_return(status: invalid_state)

            check = Check.new
            aggregate_failures('check') do
              expect(check.http_status_code).to eq(429)

              check_json = check.as_json
              expect(check_json[:status]).to eq(Status::WARN)

              details = check_json[:details]
              passing_checks.each do |p|
                expect(details[p]).to eq(Result.pass.as_json)
              end

              failure_details = details[c]
              expect(failure_details[:status]).to eq(Status::WARN.as_json)
              expect(failure_details[:output]).to include(expected_details)
            end
          end
        end
      end
    end
  end
end
