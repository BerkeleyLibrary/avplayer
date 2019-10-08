require 'rest-client'

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

    # @param tind_id [Tind::Id] the TIND ID to find
    def find_marc_record(tind_id)
      raise 'tind_search_url not configured in Rails application' unless tind_search_url

      records = find_marc_records(tind_id)
      marc_record = records.first
      return unless marc_record

      marc_record if tind_id.in?(marc_record)
    end

    def tind_search_url
      Rails.application.config.tind_search_url
    end

    private

    # @return [Enumerable<MARC::Record>]
    def find_marc_records(tind_id)
      marc_xml = get_marc_xml(tind_id.value)
      input = StringIO.new(marc_xml)
      MARC::XMLReader.new(input) # MARC::XMLReader mixes in Enumerable
    end

    def get_marc_xml(id_value)
      tind_search_params = { p: id_value, of: 'xm' }
      Rails.logger.debug("getting: #{tind_search_uri(tind_search_params)}")
      resp = RestClient.get(tind_search_url, params: tind_search_params)
      if resp.code != 200
        uri = tind_search_uri(tind_search_params)
        Rails.logger.error("GET #{uri} returned #{resp.code}: #{resp.body}")
        return nil
      end
      # TODO: stream response https://github.com/rest-client/rest-client#streaming-responses
      resp.body
    end

    def tind_search_uri(tind_search_params)
      uri = URI.parse(tind_search_url)
      uri.query = tind_search_params.to_query
      uri
    end

  end
end
