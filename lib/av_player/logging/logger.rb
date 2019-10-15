require 'active_support'
require 'ougai/logger'
require 'av_player/logging/formatters'

module AvPlayer
  module Logging
    class Logger < Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include ActiveSupport::LoggerSilence
    end
  end
end
