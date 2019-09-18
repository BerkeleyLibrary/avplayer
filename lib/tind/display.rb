Dir.glob(File.expand_path('display/*.rb', __dir__)).sort.each(&method(:require))
