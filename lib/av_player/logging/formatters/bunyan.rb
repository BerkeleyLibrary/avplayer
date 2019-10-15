require 'ougai/formatters/bunyan'
require 'av_player/logging/ensure_hash'

module AvPlayer
  module Logging
    module Formatters
      class Bunyan < Ougai::Formatters::Bunyan

        def _call(severity, time, progname, data)
          # Ougai::Formatters::Bunyan replaces the human-readable severity string
          # with a numeric level, so we add it here as a separate attribute
          original_data = AvPlayer::Logging.ensure_hash(data)
          merged_data = { severity: severity }.merge(original_data)
          super(severity, time, progname, merged_data)
        end

      end
    end
  end
end
