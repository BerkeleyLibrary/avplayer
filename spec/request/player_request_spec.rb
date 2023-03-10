require 'rails_helper'
require 'health/check'

describe PlayerController, type: :request do
  before do
    BerkeleyLibrary::AV::Config.wowza_base_uri = 'https://wowza.example.edu/'
  end

  describe :health do
    it 'returns the health check result' do
      expected_status = 200
      expected_json = {
        'status' => 'pass',
        'details' => Health::Check.all_checks.keys.to_h { |c| [c, 'pass'] }
      }

      check = instance_double(Health::Check)
      allow(check).to receive(:as_json).and_return(expected_json)
      allow(check).to receive(:http_status_code).and_return(expected_status)

      allow(Health::Check).to receive(:new).and_return(check)

      get health_path
      expect(response).to have_http_status(:ok)

      expect(JSON.parse(response.body)).to eq(expected_json)
    end
  end

  describe :index do
    it 'includes build information in comments' do
      stub_sru_request('b23305522')
      manifest_url = 'https://wowza.example.edu/Pacifica/mp3:PRA_NHPRC1_AZ1084_00_000_00.mp3/playlist.m3u8'
      stub_request(:head, manifest_url).to_return(status: 200)

      get '/Pacifica/b23305522'

      expect(response.body).to include(AvPlayer::BuildInfo.as_html_comment)
    end
  end
end
