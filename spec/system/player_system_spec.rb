require 'rails_helper'

describe PlayerController, type: :system do

  describe 'audio' do
    before(:each) do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b23305522/.b23305522/1%2C1%2C1%2CB/marc~b23305522'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b23305522.html'))

      visit root_url + 'Pacifica/b23305522'
    end

    it 'displays the metadata' do
      metadata = AV::Metadata.for_record(record_id: 'b23305522')
      page_body = page.body

      aggregate_failures('fields') do
        metadata.values.each do |f|
          expect(page).to have_content(f.label)
          if f.respond_to?(:links)
            f.links.each { |link| expect(page).to have_link(link.body, href: link.url) }
          elsif f.respond_to?(:lines)
            f.lines.each do |line|
              escaped_line = ERB::Util.html_escape(line)
              # page.has_text? chokes on long lines for some reason
              expect(page_body).to include(escaped_line)
            end
          end
        end
      end
    end

    it 'displays the player' do
      wowza_base_uri = Rails.application.config.wowza_base_uri
      collection = 'Pacifica'
      path = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
      expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end
  end

  describe 'multiple files' do
    it 'displays multiple players for multiple audio files' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b11082434/.b11082434/1%2C1%2C1%2CB/marc~b11082434'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b11082434.html'))

      visit root_url + 'MRCAudio/b11082434'

      wowza_base_uri = Rails.application.config.wowza_base_uri
      collection = 'MRCAudio'
      %w[frost-read1.mp3 frost-read2.mp3].each do |path|
        expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"
        source = find(:xpath, '//source[@src="' + expected_url + '"]')
        expect(source).not_to be_nil
      end
    end
  end

  describe 'video' do
    attr_reader :metadata_key
    attr_reader :metadata_record

    before(:each) do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
      visit root_url + 'MRCVideo/b22139658'
    end

    it 'displays the metadata' do
      metadata = AV::Metadata.for_record(record_id: 'b22139658')
      page_body = page.body

      aggregate_failures('fields') do
        metadata.values.each do |f|
          expect(page).to have_content(f.label)
          if f.respond_to?(:links)
            f.links.each { |link| expect(page).to have_link(link.body, href: link.url) }
          elsif f.respond_to?(:lines)
            f.lines.each do |line|
              escaped_line = ERB::Util.html_escape(line)
              # page.has_text? chokes on long lines for some reason
              expect(page_body).to include(escaped_line)
            end
          end
        end
      end
    end

    it 'displays the player' do
      video_base_uri = Rails.application.config.video_base_uri
      path = 'mrc/6927.mp4'
      expected_url = "#{video_base_uri}#{path}"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end
  end

  describe 'record not found' do
    it 'displays the "Record not found" page for an invalid record ID' do
      visit root_url + 'Pacifica/abcdefg'
      expect(page).to have_content('Record not found')
      expect(page).to have_content('abcdefg')
    end

    it 'displays the "Record not found" page when records aren\'t found' do
      stub_request(:get, 'https://digicoll.lib.berkeley.edu/record/21178/export/xm').to_return(status: 404)
      visit root_url + 'Pacifica/21178'
      expect(page).to have_content('Record not found')
      expect(page).to have_content('21178')
    end

    it 'displays the "Record not found" page for UCB-only records' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b18538031/.b18538031/1%2C1%2C1%2CB/marc~b18538031'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b18538031.html'))
      visit root_url + 'City/b18538031'

      expect(page).to have_content('Record not found')
      expect(page).to have_content('City')
      expect(page).to have_content('b18538031')
    end
  end
end
