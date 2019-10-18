require 'active_support/tagged_logging'
require 'ougai/formatters/bunyan'

# Monkey-patch ActiveSupport::TaggedLogging::Formatter
# not to produce garbage by prepending tags to hashes.
module ActiveSupport
  module TaggedLogging
    module Formatter
      def call(severity, time, progname, data)
        return super unless current_tags.present?

        original_data = AvPlayer::Logging.ensure_hash(data)
        merged_data = { tags: current_tags }.merge(original_data)
        super(severity, time, progname, merged_data)
      end
    end
  end
end

module AvPlayer
  module Logging

    class << self
      # Configures application logging and sets a custom logger.
      #
      # @param config [Application::Configuration] the application configuration
      def configure(config)
        # noinspection RubyResolve
        lograge = config.lograge
        lograge.enabled = true
        lograge.custom_options = method(:extract_event_data)
        lograge.formatter = Formatters::Lograge.new

        logger = new_custom_logger
        config.logger = logger
        Webpacker::Instance.logger = logger
      end

      def new_custom_logger
        return new_file_logger(Formatters.readable) if Rails.env.test?

        default_json_logger = new_stdout_logger(Formatters.json)
        return default_json_logger if Rails.env.production?

        readable_logger = new_file_logger(Formatters.readable)
        default_json_logger.extend Ougai::Logger.broadcast(readable_logger)
        default_json_logger
      end

      def extract_event_data(event)
        event_data = { time: Time.now }
        extracted_headers = extract_headers(event)
        event_data.merge(extracted_headers)
      end

      def ensure_hash(message)
        return {} unless message
        return message if message.is_a?(Hash)

        { msg: message }
      end

      private

      # rubocop:disable Metrics/MethodLength
      def extract_headers(event)
        headers = event.payload[:headers]
        return {} unless headers

        extracted_headers = {
          # yes, RFC 2616 uses a variant spelling for 'referrer', it's a known issue
          # https://tools.ietf.org/html/rfc2616#section-14.36
          referer: headers['HTTP_REFERER'],
          turbolinks_referrer: headers['HTTP_TURBOLINKS_REFERRER'],
          request_id: headers['action_dispatch.request_id'],
          remote_ip: headers['action_dispatch.remote_ip'],
          remote_addr: headers['REMOTE_ADDR'],
          x_forwarded_for: headers['HTTP_X_FORWARDED_FOR']
        }

        # Some of these 'headers' include recursive structures
        # that cause SystemStackErrors in JSON serialization,
        # so we convert them all to strings
        extracted_headers.map { |k, v| [k, v.to_s] }.to_h
      end
      # rubocop:enable Metrics/MethodLength

      def new_stdout_logger(formatter)
        logger = Logger.new($stdout)
        logger.formatter = formatter
        logger
      end

      def new_file_logger(formatter)
        logger = Logger.new("log/#{Rails.env}.log")
        logger.formatter = formatter
        logger
      end
    end

    class Logger < Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include ActiveSupport::LoggerSilence
    end

    module Formatters

      class << self
        def json
          Bunyan.new
        end

        def readable
          Ougai::Formatters::Readable.new
        end

      end

      class Bunyan < Ougai::Formatters::Bunyan
        include Ougai::Logging::Severity

        def _call(severity, time, progname, data)
          original_data = Logging.ensure_hash(data)

          # Ougai::Formatters::Bunyan replaces the human-readable severity string
          # with a numeric level, so we add it here as a separate attribute
          severity = ensure_human_readable(severity)
          merged_data = { severity: severity }.merge(original_data)
          super(severity, time, progname, merged_data)
        end

        private

        def ensure_human_readable(severity)
          return to_label(severity) if severity.is_a?(Integer)

          severity.to_s
        end
      end

      class Lograge
        def call(data)
          { msg: 'Request', request: Logging.ensure_hash(data) }
        end
      end

    end

  end
end
