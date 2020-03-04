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

    describe :streaming_uri do
      it 'generates a Wowza URL' do
        track = Track.new(sort_order: 0, path: 'coll/foo.mp3')
        streaming_uri = track.streaming_uri
        expect(streaming_uri).not_to(be_nil)
        expect(streaming_uri.path).to eq('/coll/mp3:foo.mp3/playlist.m3u8')
      end

      it 'injects _definst_ into Wowza URLs with subdirectories' do
        track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp3')
        streaming_uri = track.streaming_uri
        expect(streaming_uri).not_to(be_nil)
        expect(streaming_uri.path).to eq('/coll/_definst_/mp3:foo/bar/baz.mp3/playlist.m3u8')
      end

      it 'sets the file type correctly for MP4s' do
        track = Track.new(sort_order: 0, path: 'coll/foo/bar/baz.mp4')
        streaming_uri = track.streaming_uri
        expect(streaming_uri).not_to(be_nil)
        expect(streaming_uri.path).to eq('/coll/_definst_/mp4:foo/bar/baz.mp4/playlist.m3u8')
      end
    end
  end
end
