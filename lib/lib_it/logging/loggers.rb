require 'lib_it/logging/formatters'
require 'lib_it/logging/tagged_logging_extensions'

module LibIT
  module Logging
    module Loggers
      class << self
        def new_default_logger
          return new_test_logger if Rails.env.test?
          return new_production_logger if Rails.env.production?
          return new_development_logger if Rails.env.development?
        end

        def new_json_logger(logdev)
          new_logger_with(logdev: logdev, formatter: Formatters.new_json_formatter)
        end

        def new_readable_logger(logdev)
          new_logger_with(logdev: logdev, formatter: Formatters.new_readable_formatter)
        end

        private

        def new_test_logger
          file_logger_for_env(:test)
        end

        def new_production_logger
          new_json_logger($stdout)
        end

        def new_development_logger
          new_json_logger($stdout).tap do |json_logger|
            file_logger = file_logger_for_env(:dev)
            json_logger.extend Ougai::Logger.broadcast(file_logger)
          end
        end

        def file_logger_for_env(env)
          new_readable_logger("log/#{env}.log")
        end

        def new_logger_with(logdev:, formatter:)
          AvLogger.new(logdev).tap { |l| l.formatter = formatter }
        end
      end

      class AvLogger < Ougai::Logger
        include ActiveSupport::LoggerThreadSafeLevel
        include ActiveSupport::LoggerSilence
      end
    end
  end
end
