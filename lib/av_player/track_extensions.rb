require 'av/core'
require 'nokogiri'
require 'net/http'

module AV
  class Track
    COLLECTION_RE = %r{(^[^/]+)/}

    SOURCE_TYPE_HLS = 'application/x-mpegURL'.freeze
    SOURCE_TYPE_MPEG_DASH = 'application/dash+xml'.freeze
    DASH_VTT_XPATH = "//AdaptationSet[@mimeType='text/vtt']//BaseURL".freeze

    MISSING_TRACK_PARTIAL = 'missing'.freeze

    def hls_uri
      return @hls_uri if instance_variable_defined?(:@hls_uri)

      @hls_uri ||= build_hls_uri
    end

    def mpeg_dash_uri
      return @mpeg_dash_uri if instance_variable_defined?(:@mpeg_dash_uri)

      @mpeg_dash_uri ||= build_mpeg_dash_uri
    end

    def dash_vtt_uri
      return @dash_vtt_uri if instance_variable_defined?(:@dash_vtt_uri)

      @dash_vtt_uri ||= find_dash_vtt_uri
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
      log.warn(message)

      nil
    end

    def type_label
      file_type.label
    end

    def exists?
      return @exists if instance_variable_defined?(:@exists)

      @exists = hls_uri_exists?
    end

    def player_partial
      exists? ? file_type.player_tag : MISSING_TRACK_PARTIAL
    end

    private

    def build_hls_uri
      Track.hls_uri_for(collection: collection, relative_path: relative_path)
    rescue URI::InvalidURIError => e
      log_invalid_uri(relative_path, e)
    end

    def build_mpeg_dash_uri
      Track.mpeg_dash_uri_for(collection: collection, relative_path: relative_path)
    rescue URI::InvalidURIError => e
      log_invalid_uri(relative_path, e)
    end

    def find_dash_vtt_uri
      return unless (dash_uri = mpeg_dash_uri)
      return unless (dash_manifest = do_get(dash_uri, ignore_errors: true))

      xml = Nokogiri::XML(dash_manifest)
      xml.remove_namespaces!
      return unless (dash_vtt_path_relative = xml.search(DASH_VTT_XPATH).map(&:text).first)

      dash_uri.merge(dash_vtt_path_relative)
    end

    def relative_path
      @relative_path ||= begin
        relative_path = path.sub(COLLECTION_RE, '')
        Track.url_safe(relative_path)
      end
    end

    def hls_uri_exists?
      return false unless hls_uri
      return false unless (response = make_head_request(hls_uri))

      [200, 302].include?(response.code.to_i)
    end

    def make_head_request(uri)
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(Net::HTTP::Head.new(uri)) }
    end

    class << self
      def hls_uri_for(collection:, relative_path:)
        file_type = Types::FileType.for_path(relative_path)
        collection_path = collection_path_for(collection, relative_path)
        URI.join(wowza_base_uri, "#{collection_path}/#{file_type.prefix}:#{relative_path}/playlist.m3u8")
      end

      def mpeg_dash_uri_for(collection:, relative_path:)
        collection_path = collection_path_for(collection, relative_path)
        file_type = Types::FileType.for_path(relative_path)
        URI.join(wowza_base_uri, "#{collection_path}/#{file_type.prefix}:#{relative_path}/manifest.mpd")
      end

      def url_safe(relative_path)
        # TODO: should we try to handle more exotic issues than spaces?
        relative_path.gsub(' ', '%20')
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
