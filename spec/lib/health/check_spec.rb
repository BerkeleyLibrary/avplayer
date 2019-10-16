require 'rails_helper'

require 'health'
require 'millennium'
require 'tind'

module Health
  describe Check do
    attr_reader :wowza_stream_url, :millennium_marc_url, :tind_marc_url, :all_checks

    before(:each) do
      av_file = AvFile.new(collection: Check::TEST_WOWZA_COLLECTION, path: Check::TEST_WOWZA_PATH)
      @wowza_stream_url = av_file.streaming_url

      @millennium_marc_url = Millennium.marc_url_for(Check::TEST_BIB_NUMBER)
      @tind_marc_url = Tind.marc_url_for(Check::TEST_TIND_ID)

      @all_checks = {
        Check::MILLENNIUM_CHECK => millennium_marc_url,
        Check::TIND_CHECK => tind_marc_url,
        Check::WOWZA_CHECK => wowza_stream_url
      }
    end

    describe 'success' do
      it 'returns PASS if all services are up' do
        all_checks.values.each do |service_url|
          stub_request(:head, service_url).to_return(status: 200)
        end

        check = Check.new
        aggregate_failures('check') do
          expect(check.http_status_code).to eq(200)

          check_json = check.as_json
          expect(check_json[:status]).to eq(Status::PASS)

          details = check_json[:details]
          all_checks.keys.each do |c|
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

      Check.all_checks.keys.each do |c|
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
