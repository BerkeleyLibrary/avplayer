require 'rails_helper'

RSpec.describe 'OKComputer', type: :request do
  before do
    stub_sru_head_request('b23305522')

    manifest_url = 'https://wowza.lib.berkeley.edu/Pacifica/mp3:PRA_NHPRC1_AZ1084_00_000_00.mp3/playlist.m3u8'
    stub_request(:head, manifest_url).to_return(status: 200)

    record_id = '(pacradio)01469'
    tind_url = BerkeleyLibrary::AV::Metadata::Source::TIND.marc_uri_for(record_id)
    stub_request(:get, tind_url).to_return(status: 200, body: File.read("spec/data/record-#{record_id}.xml"))
  end

  it 'is mounted at /okcomputer' do
    get '/okcomputer'
    expect(response).to have_http_status :ok
  end

  it 'returns all checks to /health' do
    get '/health'

    expect(response).to have_http_status :ok
    expect(response.parsed_body.keys).to match_array %w[
      alma-metadata
      default
      tind-metadata
      wowza-streaming
    ]
  end

  it 'fails when TIND lookups fail' do
    expect(BerkeleyLibrary::AV::Record).to receive(:from_metadata).and_raise('Something bad happened')
    get '/health'
    expect(response).not_to have_http_status :ok
  end
end
