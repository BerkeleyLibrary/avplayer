require 'action_view/buffers'
require 'cgi'

require 'berkeley_library/logging'

module AvPlayer
  class BuildInfo

    MULTIPLE_HYPHEN_ESCAPE_RE = /((?<=-)-)|(-(?=-))/
    HYPHEN_ENTITY_ESCAPE = '&#45;'.freeze

    BUILD_VARS = %w[CI BUILD_TIMESTAMP BUILD_URL DOCKER_TAG GIT_REF_NAME GIT_SHA GIT_REPOSITORY_URL].freeze

    attr_reader :info

    def initialize(env = ENV)
      @info = info_from_env(env)
    end

    alias to_h info
    alias to_hash info

    def as_html_comment
      @html_comment ||= build_html_comment
    end

    private

    def info_from_env(env)
      {}.tap do |info|
        BUILD_VARS.each do |var|
          next unless (val = env[var])

          info[var.to_sym] = val.to_s
        end
      end.freeze
    end

    # rubocop:disable Rails/OutputSafety
    def build_html_comment
      comment_lines = [].tap do |lines|
        lines << '<!--'
        info.each { |k, v| lines << "  #{k}: #{escape_comment(v)}" }
        lines << '-->'
      end
      comment_lines.join("\n").html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def escape_comment(v)
      v ? v.to_s.gsub(MULTIPLE_HYPHEN_ESCAPE_RE, HYPHEN_ENTITY_ESCAPE) : '<nil>'
    end

    class << self
      def build_info
        @build_info ||= BuildInfo.new
      end

      def log_to(logger)
        logger.info('Build', data: build_info)
      end

      def as_html_comment
        build_info.as_html_comment
      end
    end
  end
end
