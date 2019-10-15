require 'rails_helper'

module AvPlayer
  module Logging
    describe Formatters do
      describe :json do
        it 'supports tagged logging' do
          out = StringIO.new
          logger = Logger.new(out)
          logger.formatter = Formatters.json

          logger = ActiveSupport::TaggedLogging.new(logger)

          expected_tag = 'hello'
          expected_msg = 'this is a test'

          logger.tagged(expected_tag) do
            logger.info(expected_msg)
          end

          logged_json = JSON.parse(out.string)
          expect(logged_json['msg']).to eq(expected_msg)
          expect(logged_json['tags']).to eq([expected_tag])
        end
      end
    end
  end
end
