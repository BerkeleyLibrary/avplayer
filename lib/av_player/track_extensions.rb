require 'av/core'

module AV
  class Track
    COLLECTION_RE = %r{(^[^/]+)/}.freeze

    def mime_type
      file_type.mime_type
    end

    def streaming_uri
      Track.streaming_uri_for(collection: collection, relative_path: relative_path)
    end

    private

    def collection
      @collection ||= begin
        match_data = COLLECTION_RE.match(path)
        match_data && match_data[1]
      end
    end

    def relative_path
      @relative_path ||= path.sub(COLLECTION_RE, '')
    end

    class << self
      def streaming_uri_for(collection:, relative_path:)
        file_type = Types::FileType.for_path(relative_path)
        return mp4_path(relative_path) if file_type == Types::FileType::MP4

        mp3_path(collection, relative_path) if file_type == Types::FileType::MP3
      end

      private

      def mp4_path(relative_path)
        URI.join(video_base_uri, relative_path)
      rescue URI::InvalidURIError => e
        log_invalid_uri(relative_path, e)
      end

      def mp3_path(collection, relative_path)
        URI.join(wowza_base_uri, "#{collection}/mp3:#{relative_path}/playlist.m3u8")
      rescue URI::InvalidURIError => e
        log_invalid_uri(relative_path, e)
      end

      def wowza_base_uri
        Rails.application.config.wowza_base_uri
      end

      def video_base_uri
        Rails.application.config.video_base_uri
      end

      def log_invalid_uri(relative_path, e)
        message = "Error parsing relative path #{relative_path.inspect}"
        message << "#{e.class} (#{e.message}):\n"
        message << "  " << e.backtrace.join("\n  ")
        Rails.logger.warn(message)

        nil
      end
    end

  end
end
