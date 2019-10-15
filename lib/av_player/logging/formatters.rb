Dir.glob(File.expand_path('formatters/*.rb', __dir__)).sort.each(&method(:require))

module AvPlayer
  module Logging
    module Formatters
      class << self
        def json
          Bunyan.new
        end

        def readable
          Ougai::Formatters::Readable.new
        end
      end
    end
  end
end
