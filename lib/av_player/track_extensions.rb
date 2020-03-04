require 'av/core'

module AV
  class Track
    COLLECTION_RE = %r{(^[^/]+)/}.freeze

    def mime_type
      file_type.mime_type
    end

    # @return [URI::HTTP] the streaming URI
    def streaming_uri
      Track.streaming_uri_for(collection: collection, relative_path: relative_path)
    end

    def collection
      @collection ||= begin
        match_data = COLLECTION_RE.match(path)
        match_data && match_data[1]
      end
    end

    private

    def relative_path
      @relative_path ||= path.sub(COLLECTION_RE, '')
    end

    class << self
      def streaming_uri_for(collection:, relative_path:)
        file_type = Types::FileType.for_path(relative_path)
        # shenanigans to get Wowza to recognize subdirectories
        # see https://www.wowza.com/community/answers/55056/view.html
        collection_path = collection_path_for(collection, relative_path)
        URI.join(wowza_base_uri, "#{collection_path}/#{file_type}:#{relative_path}/playlist.m3u8")
      rescue URI::InvalidURIError => e
        log_invalid_uri(relative_path, e)
      end

      private

      def collection_path_for(collection, relative_path)
        relative_path.include?('/') ? "#{collection}/_definst_" : collection
      end

      def wowza_base_uri
        AV::Config.wowza_base_uri
      end

      def video_base_uri
        Rails.application.config.video_base_uri
      end

      def log_invalid_uri(relative_path, e)
        message = "Error parsing relative path #{relative_path.inspect}"
        message << "#{e.class} (#{e.message}):\n"
        message << '  ' << e.backtrace.join("\n  ")
        Rails.logger.warn(message)

        nil
      end
    end

  end
end
