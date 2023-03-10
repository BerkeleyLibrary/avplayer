require 'berkeley_library/av/core'
require 'nokogiri'
require 'net/http'
require 'berkeley_library/logging'

module BerkeleyLibrary
  module AV
    class Track
      include BerkeleyLibrary::Logging

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
        @collection ||= (match_data = COLLECTION_RE.match(path)) && match_data[1]
      end

      def type_label
        file_type.label
      end

      def exists?
        return @exists if instance_variable_defined?(:@exists)

        @exists = hls_uri_exists? || false
      end

      def player_partial
        exists? ? file_type.player_tag : MISSING_TRACK_PARTIAL
      end

      def relative_path
        @relative_path ||= (rp_raw = path.sub(COLLECTION_RE, '')) && Track.url_safe(rp_raw)
      end

      private

      def build_hls_uri
        Track.hls_uri_for(collection:, relative_path:)
      rescue URI::InvalidURIError => e
        log_invalid_uri(relative_path, e)
      end

      def build_mpeg_dash_uri
        Track.mpeg_dash_uri_for(collection:, relative_path:)
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

      def hls_uri_exists?
        return nil_with_warning("No HLS URI for track: #{self}") unless hls_uri
        return nil_with_warning("HEAD request for #{hls_uri} did not return a response") unless (response = make_head_request(hls_uri))
        return true if [200, 302].include?(response.code.to_i)

        nil_with_warning("HEAD request for #{hls_uri} returned #{response.code}")
      end

      def make_head_request(uri)
        Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) { |http| http.request(Net::HTTP::Head.new(uri)) }
      end

      def log_invalid_uri(relative_path, e)
        msg = ["Error parsing relative path #{relative_path.inspect} (#{e.class} (#{e.message})"]
        msg.concat(e.backtrace) if e.backtrace

        nil_with_warning(msg.join("\n  "))
      end

      def nil_with_warning(msg)
        nil
      ensure
        logger.warn(msg)
      end

      class << self
        def hls_uri_for(collection:, relative_path:)
          file_type = Types::FileType.for_path(relative_path)
          collection_path = collection_path_for(collection, relative_path)
          URI.join(wowza_base_uri, "/#{collection_path}/#{file_type.prefix}:#{relative_path}/playlist.m3u8")
        end

        def mpeg_dash_uri_for(collection:, relative_path:)
          collection_path = collection_path_for(collection, relative_path)
          file_type = Types::FileType.for_path(relative_path)
          URI.join(wowza_base_uri, "/#{collection_path}/#{file_type.prefix}:#{relative_path}/manifest.mpd")
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
end
