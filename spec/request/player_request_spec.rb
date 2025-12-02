require 'rails_helper'

describe PlayerController, type: :request do
  before do
    BerkeleyLibrary::AV::Config.wowza_base_uri = 'https://wowza.example.edu/'
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
