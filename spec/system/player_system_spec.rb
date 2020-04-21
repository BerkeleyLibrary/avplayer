require 'rails_helper'

describe PlayerController, type: :system do

  describe 'audio' do
    before(:each) do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b23305522/.b23305522/1%2C1%2C1%2CB/marc~b23305522'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b23305522.html'))

      visit '/Pacifica/b23305522'
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
      wowza_base_uri = AV::Config.wowza_base_uri
      collection = 'Pacifica'
      path = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
      expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end

    it 'displays the catalog link' do
      expect(page).to have_link('View library catalog record.', href: 'http://oskicat.berkeley.edu/record=b23305522')
    end
  end

  describe 'multiple files' do
    it 'displays multiple players for multiple audio files' do
      collection = 'MRCAudio'
      bib_number = 'b11082434'

      search_url = "http://oskicat.berkeley.edu/search~S1?/.#{bib_number}/.#{bib_number}/1%2C1%2C1%2CB/marc~#{bib_number}"
      stub_request(:get, search_url).to_return(status: 200, body: File.read("spec/data/#{bib_number}.html"))

      visit "/#{collection}/#{bib_number}"

      record = AV::Record.from_metadata(collection: collection, record_id: bib_number)
      wowza_base_uri = AV::Config.wowza_base_uri

      record.tracks.each do |track|
        expect(page).to have_content(track.duration.to_s)
        expect(page).to have_content(track.title)

        path = track.path.sub("#{collection}/", '')
        expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"
        source = find(:xpath, '//source[@src="' + expected_url + '"]')
        expect(source).not_to be_nil
      end
    end
  end

  describe 'TIND records' do
    before(:each) do
      search_url = AV::Metadata::Source::TIND.marc_uri_for('(pacradio)01469')
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/record-(pacradio)01469.xml'))

      visit '/Pacifica/(pacradio)01469'
    end

    it 'displays the metadata' do
      metadata = AV::Metadata.for_record(record_id: '(pacradio)01469')
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
      wowza_base_uri = AV::Config.wowza_base_uri
      collection = 'Pacifica'
      path = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
      expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end

    it 'displays the catalog link' do
      expect(page).to have_link('View library catalog record.', href: 'http://oskicat.berkeley.edu/record=b23305522')
    end
  end

  describe 'bad track paths' do
    it 'still displays audio records' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b23305522/.b23305522/1%2C1%2C1%2CB/marc~b23305522'
      data_with_bad_path = File.read('spec/data/b23305522.html').gsub('PRA_NHPRC1_AZ1084_00_000_00.mp3', 'this is not a valid path.mp3')
      stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
      visit '/Pacifica/b23305522'

      audio = find(:xpath, '//audio')
      expect(audio).not_to be_nil
    end

    it 'still displays video records' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
      data_with_bad_path = File.read('spec/data/b22139658.html').gsub('6927.mp4', 'this is not a valid path.mp4')
      stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
      visit '/MRCVideo/b22139658'

      video = find(:xpath, '//video')
      expect(video).not_to be_nil
    end
  end

  describe 'no track info' do
    it 'still displays audio records' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b23305522/.b23305522/1%2C1%2C1%2CB/marc~b23305522'
      data_with_bad_path = File.read('spec/data/b23305522.html').gsub(/^998.*/, '')
      stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
      visit '/Pacifica/b23305522'

      expected_title = 'Wanda Coleman'
      expect(page).to have_content(expected_title)
      expect(page).to have_content('No track information found')
    end

    it 'still displays video records' do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
      data_with_bad_path = File.read('spec/data/b22139658.html').gsub(/^998.*/, '')
      stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
      visit '/MRCVideo/b22139658'

      expected_title = 'Communists on campus'
      expect(page).to have_content(expected_title)
      expect(page).to have_content('No track information found')
    end
  end

  describe 'video' do
    # http://www.lib.berkeley.edu/video/PksgQpmQEeOaQoD510pG4A

    attr_reader :metadata_key
    attr_reader :metadata_record

    before(:each) do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
      visit '/MRCVideo/b22139658'
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
      wowza_base_uri = AV::Config.wowza_base_uri
      collection = 'MRCVideo'
      path = '6927.mp4'
      expected_url = "#{wowza_base_uri}#{collection}/mp4:#{path}/manifest.mpd"

      source = find(:xpath, '//source[@src="' + expected_url + '"]')
      expect(source).not_to be_nil
    end

    it 'displays the catalog link' do
      expect(page).to have_link('View library catalog record.', href: 'http://oskicat.berkeley.edu/record=b22139658')
    end
  end

  describe 'record not found' do
    it 'displays the "Record not found" page when records aren\'t found' do
      search_url = AV::Metadata::Source::TIND.marc_uri_for('(pacradio)01469')
      stub_request(:get, search_url).to_return(status: 404)
      visit '/Pacifica/(pacradio)01469'
      expect(page).to have_content('Record not found')
      expect(page).to have_content('(pacradio)01469')

      expect(page.status_code).to eq(404)
    end
  end

  describe 'UCB-only records' do
    before(:each) do
      search_url = 'http://oskicat.berkeley.edu/search~S1?/.b18538031/.b18538031/1%2C1%2C1%2CB/marc~b18538031'
      stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b18538031.html'))
    end

    describe 'when allowed' do
      it 'displays the player for UCB IPs' do
        allow(UcbIpService).to receive(:ucb_request?).and_return(true)
        visit '/City/b18538031'

        audio = find_all(:xpath, '//audio')
        expect(audio.size).to eq(2)
      end
    end

    describe 'when forbidden' do
      it 'displays the "Record not available" page for non-UCB IPs' do
        allow(UcbIpService).to receive(:ucb_request?).and_return(false)
        visit '/City/b18538031'

        audio = find_all(:xpath, '//audio')
        expect(audio.size).to eq(0)

        expect(page).to have_content('Record not available')
        expect(page).to have_content('City')
        expect(page).to have_content('b18538031')

        expect(page.status_code).to eq(403)
      end
    end
  end
end
