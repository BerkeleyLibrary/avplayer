require 'rails_helper'

module AvPlayer
  describe Logging do
    describe :ensure_hash do
      it 'returns an empty hash for nil' do
        expect(Logging.ensure_hash(nil)).to eq({})
      end

      it 'returns the original hash for a hash' do
        original_hash = { a: 1, b: 2 }
        expect(Logging.ensure_hash(original_hash)).to equal(original_hash)
      end

      it 'wraps anything else in a hash' do
        message = 'this is a message'
        expect(Logging.ensure_hash(message)).to eq({ msg: message })
      end
    end

    describe :new_custom_logger do
      it 'returns a file logger in test' do
        logger = Logging.new_custom_logger
        expect(logger).not_to be_nil
        logdev = logger.instance_variable_get(:@logdev)
        expect(logdev.filename).to eq('log/test.log')
      end

      it 'returns a stdout logger in production' do
        env_original = Rails.env
        begin
          Rails.env = 'production'
          logger = Logging.new_custom_logger
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)
        ensure
          Rails.env = env_original
        end
      end

      it 'returns a stdout logger in development' do
        env_original = Rails.env
        begin
          Rails.env = 'development'
          logger = Logging.new_custom_logger
          expect(logger).not_to be_nil
          logdev = logger.instance_variable_get(:@logdev)
          expect(logdev.filename).to be_nil
          expect(logdev.dev).to eq($stdout)

          # TODO: come up with a succinct way to test broadcast to file
        ensure
          Rails.env = env_original
        end
      end
    end
  end
end
