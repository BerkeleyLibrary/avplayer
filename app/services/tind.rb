# TODO: consider pulling this out into a gem
Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module Tind
  class << self

    def record_factory
      @record_factory ||= begin
        json_config_path = File.join(Rails.root, 'config/tind/tind_html_metadata_da.json')
        json_config = File.read(json_config_path)
        json = JSON.parse(json_config)
        RecordFactory.from_json(json)
      end
    end
  end
end
