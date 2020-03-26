require 'spec_helper'
require 'av_player/track_extensions'

module AV
  describe Track do
    before(:each) do
      AV::Config.wowza_base_uri = 'https://wowza.example.edu/'
    end

    after(:each) do
      AV::Config.instance_variable_set(:@wowza_base_uri, nil)
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

      it 'logs an error in the event of an invalid URI' do
        track = Track.new(sort_order: 0, path: "coll/foo\tbar.mp4")
        msg_re = /foo\\tbar.mp4/
        expect(AV.logger).to receive(:warn).with(msg_re)
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
        expect(AV.logger).to receive(:warn).with(msg_re)
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
  end
end
