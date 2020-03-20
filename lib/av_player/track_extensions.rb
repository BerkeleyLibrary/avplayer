require 'av/core'

module AV
  class Track
    COLLECTION_RE = %r{(^[^/]+)/}.freeze

    # TODO: something more elegant than all this

    SOURCE_TYPE_HLS = 'application/x-mpegURL'.freeze
    SOURCE_TYPE_MPEG_DASH = 'application/dash+xml'.freeze

    def hls_uri
      Track.hls_uri_for(collection: collection, relative_path: relative_path)
    rescue URI::InvalidURIError => e
      log_invalid_uri(relative_path, e)
    end

    def mpeg_dash_uri
      Track.mpeg_dash_uri_for(collection: collection, relative_path: relative_path)
    rescue URI::InvalidURIError => e
      log_invalid_uri(relative_path, e)
    end

    def collection
      @collection ||= begin
        match_data = COLLECTION_RE.match(path)
        match_data && match_data[1]
      end
    end

    def log_invalid_uri(relative_path, e)
      message = "Error parsing relative path #{relative_path.inspect}"
      message << "#{e.class} (#{e.message}):\n"
      message << '  ' << e.backtrace.join("\n  ")
      Rails.logger.warn(message)

      nil
    end

    private

    def relative_path
      @relative_path ||= path.sub(COLLECTION_RE, '')
    end

    class << self
      def hls_uri_for(collection:, relative_path:)
        file_type = Types::FileType.for_path(relative_path)
        collection_path = collection_path_for(collection, relative_path)
        URI.join(wowza_base_uri, "#{collection_path}/#{file_type}:#{relative_path}/playlist.m3u8")
      end

      def mpeg_dash_uri_for(collection:, relative_path:)
        file_type = Types::FileType.for_path(relative_path)
        collection_path = collection_path_for(collection, relative_path)
        URI.join(wowza_base_uri, "#{collection_path}/#{file_type}:#{relative_path}/manifest.mpd")
      end

      private

      # shenanigans to get Wowza to recognize subdirectories
      # see https://www.wowza.com/community/answers/55056/view.html
      # @return [String] the collection path
      def collection_path_for(collection, relative_path)
        relative_path.include?('/') ? "#{collection}/_definst_" : collection
      end

      def wowza_base_uri
        AV::Config.wowza_base_uri
      end

    end

  end
end
