module AvPlayer
  module Logging

    class << self
      # Configures application logging and sets a custom logger.
      #
      # @param config [Application::Configuration] the application configuration
      def configure(config)
        config.lograge.enabled = true
        config.lograge.custom_options = method(:extract_event_data)
        config.lograge.formatter = LogrageRequestFormatter.new

        logger = new_custom_logger
        config.logger = logger
        Webpacker::Instance.logger = logger
      end

      def new_custom_logger
        return Logger.new if ((env = Rails.env) && env.production?)

        readable_logger = Ougai::Logger.new("log/#{env}.log")
        readable_logger.formatter = Ougai::Formatters::Readable.new
        logger = Logger.new($stdout)
        logger.extend Ougai::Logger.broadcast(readable_logger)
        logger
      end

      def extract_event_data(event)
        event_data = { time: Time.now }

        headers = event.payload[:headers]
        return event_data unless headers

        event_data[:request_id] = headers.env['action_dispatch.request_id']
        event_data[:remote_ip] = headers[:REMOTE_ADDR]

        request = headers.instance_variable_get(:@req)
        return event_data unless request

        event_data[:ip] = request.ip
        event_data
      end

    end

    class LogrageRequestFormatter
      def call(data)
        { msg: 'Request', request: data}
      end
    end

    class Logger < Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include ActiveSupport::LoggerSilence

      def initialize(*args)
        super
      end

      def create_formatter
        # TODO: intercept TaggedLogging auto-injection (tagged_logging.rb #L73)
        Ougai::Formatters::Bunyan.new
      end

      def add(severity, message = nil, progname = nil)
        message_with_severity = include_severity(message, severity)
        super(severity, message_with_severity, progname)
      end

      private

      # Ougai replaces the human-readable severity string with a numeric level,
      # so we add it here as a separate attribute
      #
      # @param message [String, Hash] the original message
      # @param severity [String]
      # @return [Hash] a message hash including the severity
      def include_severity(message, severity)
        severity_label = to_label(severity)
        ensure_hash(message).merge(severity: severity_label)
      end

      def ensure_hash(message)
        return {} unless message
        return message if message.is_a?(Hash)

        {msg: message}
      end
    end
  end

  # class Logger < Ougai::Logger
  #   include ActiveSupport::LoggerThreadSafeLevel
  #   include ActiveSupport::LoggerSilence
  #
  #   def initialize(*args)
  #     super
  #   end
  #
  #   def create_formatter
  #     LogFormatter.new
  #   end
  # end
  #
  # class LogFormatter < Ougai::Formatters::Bunyan
  #   def initialize(*args)
  #     super
  #     after_initialize if respond_to? :after_initialize
  #   end
  #
  #   def _call(severity, time, progname, data)
  #     additional_data = {
  #       name: progname || @app_name,
  #       hostname: @hostname,
  #       pid: $PID,
  #       level: severity.to_s,
  #       time: time
  #     }
  #     dump(additional_data.merge(data))
  #   end
  # end

end
