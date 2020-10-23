require 'rails_helper'

describe PlayerController, type: :system do

  before(:each) do
    AV::Config.wowza_base_uri = 'https://wowza.example.edu/'
  end

  describe :show do

    describe 'audio' do
      before(:each) do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b23305522/.b23305522/1%2C1%2C1%2CB/marc~b23305522'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b23305522.html'))
        manifest_url = 'https://wowza.example.edu/Pacifica/mp3:PRA_NHPRC1_AZ1084_00_000_00.mp3/playlist.m3u8'
        stub_request(:head, manifest_url).to_return(status: 200)

        visit '/Pacifica/b23305522'
      end

      it 'displays the metadata' do
        metadata = AV::Metadata.for_record(record_id: 'b23305522')
        page_body = page.body

        aggregate_failures('fields') do
          metadata.each_value do |f|
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

        source = find(:xpath, "//source[@src=\"#{expected_url}\"]")
        expect(source).not_to be_nil
      end

      it 'displays the catalog link' do
        expect(page).to have_link('View library catalog record.', href: 'http://oskicat.berkeley.edu/record=b23305522')
      end
    end

    describe 'multiple files' do
      it 'displays multiple players for multiple audio files' do
        collection = 'MRCAudio'
        record_id = 'b11082434'

        search_url = "http://oskicat.berkeley.edu/search~S1?/.#{record_id}/.#{record_id}/1%2C1%2C1%2CB/marc~#{record_id}"
        stub_request(:get, search_url).to_return(status: 200, body: File.read("spec/data/#{record_id}.html"))
        stub_request(:head, /playlist.m3u8$/).to_return(status: 200)

        visit "/#{collection}/#{record_id}"

        record = AV::Record.from_metadata(collection: collection, record_id: record_id)
        wowza_base_uri = AV::Config.wowza_base_uri

        record.tracks.each_with_index do |track, _index|
          expect(page).to have_content(track.duration.to_s)
          expect(page).to have_content(track.title)

          path = track.path.sub("#{collection}/", '')
          expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"
          audio = find(:xpath, "//audio[source/@src=\"#{expected_url}\"]")
          expect(audio).not_to be_nil

          # TODO: switch first track back to auto after fix for https://github.com/mediaelement/mediaelement/issues/2828
          expected_preload = 'none' # index == 0 ? 'auto' : 'none'
          expect(audio['preload']).to eq(expected_preload)
        end
      end
    end

    describe 'TIND records' do
      attr_reader :metadata

      before(:each) do
        collection = 'Pacifica'
        record_id = '(pacradio)01469'

        search_url = AV::Metadata::Source::TIND.marc_uri_for(record_id)
        stub_request(:get, search_url).to_return(status: 200, body: File.read("spec/data/record-#{record_id}.xml"))
        stub_request(:head, /playlist.m3u8$/).to_return(status: 200)

        visit "/#{collection}/#{record_id}"
      end

      it 'displays the metadata' do
        metadata = AV::Metadata.for_record(record_id: '(pacradio)01469')
        page_body = page.body

        aggregate_failures('fields') do
          metadata.each_value do |f|
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

        source = find(:xpath, "//source[@src=\"#{expected_url}\"]")
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
        stub_request(:head, /playlist.m3u8$/).to_return(status: 404)

        visit '/Pacifica/b23305522'

        expected_title = 'Wanda Coleman'
        expect(page).to have_content(expected_title)
        expect(page).to have_content('File not found')
      end

      it 'still displays video records' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        data_with_bad_path = File.read('spec/data/b22139658.html').gsub('6927.mp4', 'this is not a valid path.mp4')
        stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
        stub_request(:head, /playlist.m3u8$/).to_return(status: 404)

        visit '/Video-Public-MRC/b22139658'

        expected_title = 'Communists on campus'
        expect(page).to have_content(expected_title)
        expect(page).to have_content('File not found')
      end

      it "displays something useful when it can't determine file type" do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b25742488/.b25742488/1%2C1%2C1%2CB/marc~b25742488'
        data_with_bad_path = File.read('spec/data/b25742488.html')
        stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
        stub_request(:head, /playlist.m3u8$/).to_return(status: 404)
        visit '/Video-UCB-Only-MRC/b25742488'

        expected_title = 'Monumental crossroads'
        expect(page).to have_content(expected_title)
        expect(page).to have_content('unsupported file type')
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
        stub_request(:get, /manifest.mpd$/).to_return(status: 404)

        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        data_with_bad_path = File.read('spec/data/b22139658.html').gsub(/^998.*/, '')
        stub_request(:get, search_url).to_return(status: 200, body: data_with_bad_path)
        visit '/Video-Public-MRC/b22139658'

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
        stub_request(:get, /manifest.mpd$/).to_return(status: 404)
        stub_request(:head, /playlist.m3u8$/).to_return(status: 200)
        visit '/Video-Public-MRC/b22139658'
      end

      it 'displays the metadata' do
        metadata = AV::Metadata.for_record(record_id: 'b22139658')
        page_body = page.body

        aggregate_failures('fields') do
          metadata.each_value do |f|
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
        collection = 'Video-Public-MRC'
        path = '6927.mp4'
        expected_url = "#{wowza_base_uri}#{collection}/mp4:#{path}/manifest.mpd"

        video = find(:xpath, "//video[source/@src=\"#{expected_url}\"]")
        expect(video).not_to be_nil
      end

      it 'displays the catalog link' do
        expect(page).to have_link('View library catalog record.', href: 'http://oskicat.berkeley.edu/record=b22139658')
      end
    end

    describe 'captions' do
      it 'adds a <track/> tag for the VTT file when captions present' do
        search_url = 'http://oskicat.berkeley.edu/search~S1?/.b22139658/.b22139658/1%2C1%2C1%2CB/marc~b22139658'
        stub_request(:get, search_url).to_return(status: 200, body: File.read('spec/data/b22139658.html'))
        stub_request(:head, /playlist.m3u8$/).to_return(status: 200)

        manifest_url = 'https://wowza.example.edu/Video-Public-MRC/mp4:6927.mp4/manifest.mpd'
        stub_request(:get, manifest_url).to_return(body: File.read('spec/data/b22139658-manifest.mpd'))
        vtt_url = manifest_url.sub(%r{[^/]+$}, 'subtitles.m4s')
        visit '/Video-Public-MRC/b22139658'

        track = find(:xpath, "//track[@src=\"#{vtt_url}\"]")
        expect(track).not_to be_nil
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
          stub_request(:head, /playlist.m3u8$/).to_return(status: 200)
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

  describe :preview do
    describe :audio do
      it 'displays the player' do
        wowza_base_uri = AV::Config.wowza_base_uri
        collection = 'Pacifica'
        path = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
        expected_url = "#{wowza_base_uri}#{collection}/mp3:#{path}/playlist.m3u8"
        stub_request(:head, expected_url).to_return(status: 200)

        visit "/preview?#{URI.encode_www_form(collection: collection, relative_path: path)}"

        source = find(:xpath, "//source[@src=\"#{expected_url}\"]")
        expect(source).not_to be_nil
      end
    end

    describe :video do
      it 'displays the player' do
        stub_request(:head, /playlist.m3u8$/).to_return(status: 200)

        wowza_base_uri = AV::Config.wowza_base_uri
        collection = 'Video-Public-MRC'
        path = '6927.mp4'
        expected_url = "#{wowza_base_uri}#{collection}/mp4:#{path}/manifest.mpd"
        stub_request(:get, expected_url).to_return(body: File.read('spec/data/b22139658-manifest-no-captions.mpd'))

        visit "/preview?#{URI.encode_www_form(collection: collection, relative_path: path)}"

        source = find(:xpath, "//source[@src=\"#{expected_url}\"]")
        expect(source).not_to be_nil
      end
    end
  end

  describe 'bad request' do
    it 'returns 400 bad request for missing parameters' do
      visit '/preview'

      expect(page.status_code).to eq(400)
    end
  end
end
