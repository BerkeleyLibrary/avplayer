require 'av_player/logging/ensure_hash'

module AvPlayer
  module Logging
    module Formatters
      class Lograge
        def call(data)
          { msg: 'Request', request: AvPlayer::Logging.ensure_hash(data) }
        end
      end
    end
  end
end
