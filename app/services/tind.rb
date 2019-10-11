require 'rest-client'

# TODO: consider pulling this out into a gem
Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module Tind
  class << self

    # @param bib_number [String] the bib number to look up
    # @return [MARC::Record, nil]
    def find_marc_record(bib_number)
      raise ArgumentError, "#{bib_number} is not a string" unless bib_number.is_a?(String)
      raise 'tind_search_url not configured in Rails application' unless tind_search_url

      records = find_marc_records(bib_number)
      return unless records

      records.first
    end

    def tind_search_url
      Rails.application.config.tind_search_url
    end

    private

    # @return [Enumerable<MARC::Record>]
    def find_marc_records(bib_number)
      marc_xml = get_marc_xml(bib_number)
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
