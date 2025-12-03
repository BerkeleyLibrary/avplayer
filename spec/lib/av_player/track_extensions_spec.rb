require 'spec_helper'
require 'av_player/track_extensions'

module BerkeleyLibrary
  module AV
    describe Track do
      before do
        AV::Config.wowza_base_uri = 'https://wowza.example.edu/'
      end

      describe :collection do
        it 'treats the first path element as the collection name' do
          track = Track.new(sort_order: 0, path: 'coll/foo.mp3')
          expect(track.collection).to eq('coll')
        end

        it 'works with subdirectories' do
          track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp3')
          expect(track.collection).to eq('coll')
        end
      end

      describe :hls_uri do
        it 'generates a Wowza URL' do
          track = Track.new(sort_order: 0, path: 'coll/foo.mp3')
          hls_uri = track.hls_uri
          expect(hls_uri).not_to(be_nil)
          expect(hls_uri.path).to eq('/coll/mp3:foo.mp3/playlist.m3u8')
        end

        it 'injects _definst_ into Wowza URLs with subdirectories' do
          track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp3')
          hls_uri = track.hls_uri
          expect(hls_uri).not_to(be_nil)
          expect(hls_uri.path).to eq('/coll/_definst_/mp3:foo/bar/baz.mp3/playlist.m3u8')
        end

        it 'handles track paths with spaces' do
          track = Track.new(sort_order: 0, path: 'Video-UCBOnly-MRC/Of Kings and Paintings.mp4')
          hls_uri = track.hls_uri
          expect(hls_uri).not_to(be_nil)
          expect(hls_uri.path).to eq('/Video-UCBOnly-MRC/mp4:Of%20Kings%20and%20Paintings.mp4/playlist.m3u8')
        end

        it 'logs a warning in the event of an invalid URI' do
          track = Track.new(sort_order: 0, path: "coll/foo\tbar.mp4")
          msg_re = /foo\\tbar.mp4/ # NOTE: tab is escaped in message
          expect(BerkeleyLibrary::Logging.logger).to receive(:warn).with(msg_re)
          hls_uri = track.hls_uri
          expect(hls_uri).to be_nil
        end

        it 'respects the configured scheme, host, and port' do
          base_uri = URI.parse('http://128.32.10.147:1935/')
          allow(AV::Config).to receive(:wowza_base_uri).and_return(base_uri)

          track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp4')
          hls_uri = track.hls_uri
          expect(hls_uri.scheme).to eq(base_uri.scheme)
          expect(hls_uri.host).to eq(base_uri.host)
          expect(hls_uri.port).to eq(base_uri.port)
        end
      end

      describe :exists do
        it 'logs a warning and returns false in the event of an invalid URI' do
          track = Track.new(sort_order: 0, path: "coll/foo\tbar.mp4")
          allow(BerkeleyLibrary::Logging.logger).to receive(:warn).with(/foo\\tbar.mp4/) # from `build_hls_uri`
          expect(BerkeleyLibrary::Logging.logger).to receive(:warn).with("No HLS URI for track: #{track}") # from `hls_uri_exists?`
          expect(track.exists?).to be(false)
        end

        it 'logs a warning and returns false in the event of a nil HTTP response' do
          track = Track.new(sort_order: 0, path: 'coll/foo/bar.mp4')
          msg_re = /#{track.relative_path}/
          expect(BerkeleyLibrary::Logging.logger).to receive(:warn).with(msg_re)

          # Shouldn't happen but let's be sure
          allow(Net::HTTP).to receive(:start).and_return(nil)
          expect(track.exists?).to be(false)
        end

        it 'logs a warning and returns false in the event of a 404' do
          track = Track.new(sort_order: 0, path: 'coll/foo/bar.mp4')
          response_code = 404
          msg_re = /#{track.relative_path}.*#{response_code}/
          expect(BerkeleyLibrary::Logging.logger).to receive(:warn).with(msg_re)

          stub_request(:head, track.hls_uri).to_return(status: 404)
          expect(track.exists?).to be(false)
        end
      end

      describe :mpeg_dash_uri do
        it 'generates a Wowza URL' do
          track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp4')
          mpeg_dash_uri = track.mpeg_dash_uri
          expect(mpeg_dash_uri).not_to(be_nil)
          expect(mpeg_dash_uri.path).to eq('/coll/_definst_/mp4:foo/bar/baz.mp4/manifest.mpd')
        end

        it 'handles track paths with spaces' do
          track = Track.new(sort_order: 0, path: 'Video-UCBOnly-MRC/Of Kings and Paintings.mp4')
          mpeg_dash_uri = track.mpeg_dash_uri
          expect(mpeg_dash_uri).not_to(be_nil)
          expect(mpeg_dash_uri.path).to eq('/Video-UCBOnly-MRC/mp4:Of%20Kings%20and%20Paintings.mp4/manifest.mpd')
        end

        it 'logs an error in the event of an invalid URI' do
          track = Track.new(sort_order: 0, path: "coll/foo\tbar.mp4")
          msg_re = /foo\\tbar.mp4/
          expect(BerkeleyLibrary::Logging.logger).to receive(:warn).with(msg_re)
          mpeg_dash_uri = track.mpeg_dash_uri
          expect(mpeg_dash_uri).to be_nil
        end

        it 'respects the configured scheme, host, and port' do
          base_uri = URI.parse('http://128.32.10.147:1935/')
          allow(AV::Config).to receive(:wowza_base_uri).and_return(base_uri)

          track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp4')
          mpeg_dash_uri = track.mpeg_dash_uri
          expect(mpeg_dash_uri.scheme).to eq(base_uri.scheme)
          expect(mpeg_dash_uri.host).to eq(base_uri.host)
          expect(mpeg_dash_uri.port).to eq(base_uri.port)
        end
      end

      describe :dash_vtt_uri do
        it 'returns the DASH VTT URI' do
          track = Track.new(sort_order: 0, path: 'Video-Public-Bancroft/clir_rec_risk/cubanc_80_1_01287725a_access.mp4')
          mpeg_dash_uri = track.mpeg_dash_uri

          expected_manifest_path = '/Video-Public-Bancroft/_definst_/mp4:clir_rec_risk/cubanc_80_1_01287725a_access.mp4/manifest.mpd'
          expect(mpeg_dash_uri.path).to eq(expected_manifest_path) # just to be sure

          stub_request(:get, mpeg_dash_uri).to_return(body: File.read('spec/data/manifest.mpd'))

          expected_vtt_path = expected_manifest_path.sub(%r{[^/]+$}, 'subtitles_ridp0ta0leng_ctdata_w608427063_webvttsublist.m4s')
          expected_uri = URI.join(AV::Config.wowza_base_uri, expected_vtt_path)
          expect(track.dash_vtt_uri).to eq(expected_uri)
        end
      end
    end
  end
end
