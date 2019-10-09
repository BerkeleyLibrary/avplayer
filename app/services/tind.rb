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

    # @param marc_lookup [Tind::MarcLookup] the TIND ID to find
    # @return [MARC::Record, nil]
    def find_marc_record(marc_lookup)
      raise 'tind_search_url not configured in Rails application' unless tind_search_url

      records = find_marc_records(marc_lookup)
      return unless records

      records.each do |marc_record|
        return marc_record if marc_lookup.in?(marc_record)
      end

      nil
    end

    def tind_search_url
      Rails.application.config.tind_search_url
    end

    private

    # @return [Enumerable<MARC::Record>]
    def find_marc_records(marc_lookup)
      marc_xml = get_marc_xml(marc_lookup.value)
      input = StringIO.new(marc_xml)
      MARC::XMLReader.new(input) # MARC::XMLReader mixes in Enumerable
    end

    def get_marc_xml(id_value)
      tind_search_params = { p: id_value, of: 'xm' }
      begin
        return do_get(tind_search_params)
      rescue RestClient::Exception => e
        uri = loggable_search_uri(tind_search_params)
        log.error("GET #{uri} returned #{e}", e)
        raise ActiveRecord::RecordNotFound, "No TIND record found for p=#{id_value}; TIND returned #{e.http_code}"
      end
    end

    def log
      Rails.logger
    end

    def loggable_search_uri(tind_search_params)
      uri = URI.parse(tind_search_url)
      uri.query = tind_search_params.to_query
      uri
    end

    def do_get(tind_search_params)
      uri = loggable_search_uri(tind_search_params)
      log.debug("GET #{uri}")

      resp = RestClient.get(tind_search_url, params: tind_search_params)
      if resp.code != 200
        id_value = tind_search_params[:p]
        log.error("GET #{uri} returned #{resp.code}: #{resp.body}")
        raise ActiveRecord::RecordNotFound, "No TIND record found for p=#{id_value}; TIND returned #{resp.code}"
      end

      # TODO: stream response https://github.com/rest-client/rest-client#streaming-responses
      resp.body
    end

  end
end
