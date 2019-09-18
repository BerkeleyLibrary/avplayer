# TODO: consider pulling this out into a gem
Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))
