require 'rails_helper'

require 'webmock'

describe PlayerController, type: :request do
  describe :health do
    attr_reader :tind_id
    attr_reader :wowza_collection
    attr_reader :wowza_file
    attr_reader :stream_url

    before(:each) do
      @tind_id = Tind::Id.new(field: '901m', value: 'b23305522')

      @wowza_collection = 'Pacifica'
      @wowza_file = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'

      @stream_url = 'http://vm147.lib.berkeley.edu:1935/Pacifica/mp3:PRA_NHPRC1_AZ1084_00_000_00.mp3/playlist.m3u8'
      allow_any_instance_of(PlayerHelper).to(
        receive(:wowza_url_for)
          .with(collection: wowza_collection, file: wowza_file)
          .and_return(stream_url)
      )
    end

    it 'returns PASS if TIND and Wowza are both up' do
      marc_record = instance_double(MARC::Record)
      expect(Tind).to receive(:find_marc_record).with(tind_id).and_return(marc_record)

      stub_request(:head, stream_url).to_return(status: 200)

      get health_path
      expect(response).to have_http_status(:ok)
      expected_body = {
        'status' => 'pass',
        'details' => {
          Health::Check::TIND_CHECK => {
            'status' => 'pass'
          },
          Health::Check::WOWZA_CHECK => {
            'status' => 'pass'
          }
        }
      }
      expect(JSON.parse(response.body)).to eq(expected_body)
    end

    it 'returns WARN if TIND and Wowza are both down' do
      expect(Tind).to receive(:find_marc_record).with(tind_id).and_return(nil)
      stub_request(:head, stream_url).to_return(status: 500)

      get health_path

      expect(response).to have_http_status(:too_many_requests)

      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('warn')

      details = response_body['details']
      [Health::Check::TIND_CHECK,  Health::Check::WOWZA_CHECK].each do |check|
        expect(details[check]['status']).to eq('warn')
      end
    end

    it 'returns WARN if TIND and Wowza raise errors' do
      expect(Tind).to receive(:find_marc_record).with(tind_id).and_raise(StandardError)
      expect(RestClient).to receive(:head).with(stream_url).and_raise(StandardError)

      get health_path

      expect(response).to have_http_status(:too_many_requests)

      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('warn')

      details = response_body['details']
      [Health::Check::TIND_CHECK,  Health::Check::WOWZA_CHECK].each do |check|
        expect(details[check]['status']).to eq('warn')
      end
    end

    it 'returns WARN if TIND is down and Wowza is up' do
      expect(Tind).to receive(:find_marc_record).with(tind_id).and_return(nil)
      stub_request(:head, stream_url).to_return(status: 200)

      get health_path

      expect(response).to have_http_status(:too_many_requests)

      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('warn')

      details = response_body['details']
      expect(details[Health::Check::TIND_CHECK]['status']).to eq('warn')
      expect(details[Health::Check::WOWZA_CHECK]['status']).to eq('pass')
    end

    it 'returns WARN if TIND is up and Wowza is down' do
      marc_record = instance_double(MARC::Record)
      expect(Tind).to receive(:find_marc_record).with(tind_id).and_return(marc_record)

      # In general, RestClient throws exceptions for 4xx, 5xx, etc.,
      # and follows redirects for 3xx. 206 Partial Content isn't a
      # legit Wowza response, but let's just make sure we'd treat an
      # unexpected 'non-error' response as an error.
      stub_request(:head, stream_url).to_return(status: 206)

      get health_path

      expect(response).to have_http_status(:too_many_requests)

      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('warn')

      details = response_body['details']
      expect(details[Health::Check::TIND_CHECK]['status']).to eq('pass')
      expect(details[Health::Check::WOWZA_CHECK]['status']).to eq('warn')
    end
  end
end
