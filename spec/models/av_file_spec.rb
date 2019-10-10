require 'rails_helper'

describe AvFile do

  attr_reader :audio_file, :video_file

  before(:each) do
    @audio_file = AvFile.new(collection: 'Pacifica', path: 'PRA_NHPRC1_AZ1084_00_000_00.mp3')
    @video_file = AvFile.new(collection: 'MRC', path: 'mrc/6927.mp4')
  end

  describe :new do
    it 'requires a collection' do
      expect { AvFile.new(collection: nil, path: 'PRA_NHPRC1_AZ1084_00_000_00.mp3') }.to raise_error(ArgumentError)
    end

    it 'requires a path' do
      expect { AvFile.new(collection: 'Pacifica', path: nil) }.to raise_error(ArgumentError)
    end

    it 'validates the file type' do
      expect { AvFile.new(collection: 'MRC', path: 'mrc/1234.qt') }.to raise_error(ArgumentError)
    end
  end

  describe :type do
    it 'is inferred from the filename' do
      expect(audio_file.type).to eq(AvFileType::MP3)
      expect(video_file.type).to eq(AvFileType::MP4)
    end
  end

  describe :mime_type do
    it 'is based on the type' do
      expect(audio_file.mime_type).to eq('application/x-mpegURL')
      expect(video_file.mime_type).to eq('video/mp4')
    end
  end

  describe :streaming_url do
    it 'returns the streaming URL for audio' do
      wowza_base_url = Rails.application.config.wowza_base_url
      expected_url = "#{wowza_base_url}Pacifica/mp3:PRA_NHPRC1_AZ1084_00_000_00.mp3/playlist.m3u8"

      expect(audio_file.streaming_url).to eq(expected_url)
    end

    it 'returns the streaming URL for video' do
      video_base_url = Rails.application.config.video_base_url
      expected_url = "#{video_base_url}mrc/6927.mp4"

      expect(video_file.streaming_url).to eq(expected_url)
    end
  end
end
