module AvPlayer
  module Logging
    class << self
      def ensure_hash(message)
        return {} unless message
        return message if message.is_a?(Hash)

        { msg: message }
      end
    end
  end
end
