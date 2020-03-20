require 'av/core'

module AV
  class Track
    COLLECTION_RE = %r{(^[^/]+)/}.freeze

    # TODO: something more elegant than all this

    SOURCE_TYPES = {
      AV::Types::FileType::MP3 => 'application/x-mpegURL'.freeze,
      AV::Types::FileType::MP4 => 'application/dash+xml'.freeze
    }.freeze

    SOURCE_URI_METHODS = {
      AV::Types::FileType::MP3 => :hls_uri_for,
      AV::Types::FileType::MP4 => :mpeg_dash_uri_for
    }.freeze

    def source_type
      SOURCE_TYPES[file_type]
    end

    def streaming_uri
      source_uri_method = SOURCE_URI_METHODS[file_type]
      Track.send(source_uri_method, collection: collection, relative_path: relative_path)
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
