require 'rails_helper'

module LibIT
  module Logging
    describe Loggers do
      describe :new_json_logger do
        it 'supports tagged logging' do
          out = StringIO.new
          logger = Loggers.new_json_logger(out)
          logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          logger.tagged(expected_tag) { logger.info(expected_msg) }

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end
      end

      describe :new_default_logger do
        before(:each) do
          @env_original = Rails.env
        end

        after(:each) do
          Rails.env = @env_original
        end

        it 'returns a file logger in test' do
          logger = Loggers.new_default_logger
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to eq('log/test.log')
        end

        it 'returns a stdout logger in production' do
          Rails.env = 'production'
          logger = Loggers.new_default_logger
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)
        end

        it 'returns a stdout logger in development' do
          Rails.env = 'development'
          logger = Loggers.new_default_logger
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)

          # TODO: come up with a succinct way to test broadcast to file
        end
      end
    end
  end
end
