Dir.glob(File.expand_path('logging/*.rb', __dir__)).sort.each(&method(:require))

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

        headers = event.payload[:headers]
        return event_data unless headers

        event_data[:request_id] = headers.env['action_dispatch.request_id']
        event_data[:remote_ip] = headers[:REMOTE_ADDR]

        request = headers.instance_variable_get(:@req)
        return event_data unless request

        event_data[:ip] = request.ip
        event_data
      end

      private

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
  end
end
