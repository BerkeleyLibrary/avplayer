require 'rest-client'

Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module Tind
  class << self

    # @param bib_number [String] the bib number to look up
    # @return [MARC::Record, nil]
    def find_marc_record(bib_number)
      raise ArgumentError, "#{bib_number || 'nil'} is not a string" unless bib_number.is_a?(String)
      raise 'tind_search_url not configured in Rails application' unless tind_search_url

      records = find_marc_records(bib_number)
      return unless records

      records.first
    end

    def tind_search_url
      Rails.application.config.tind_search_url
    end

    def marc_url_for(bib_number)
      loggable_search_url(tind_params_for(bib_number))
    end

    private

    # @return [Enumerable<MARC::Record>]
    def find_marc_records(bib_number)
      marc_xml = get_marc_xml(bib_number)
      input = StringIO.new(marc_xml)
      MARC::XMLReader.new(input) # MARC::XMLReader mixes in Enumerable
    end

    def get_marc_xml(bib_number)
      tind_search_params = tind_params_for(bib_number)
      begin
        return do_get(tind_search_params)
      rescue RestClient::Exception => e
        uri = marc_url_for(bib_number)
        log.error("GET #{uri} returned #{e}", e)
        raise ActiveRecord::RecordNotFound, "No TIND record found for p=#{bib_number}; TIND returned #{e.http_code}"
      end
    end

    def tind_params_for(bib_number)
      { p: bib_number, of: 'xm' }
    end

    def loggable_search_url(tind_search_params)
      uri = URI.parse(tind_search_url)
      uri.query = tind_search_params.to_query
      uri.to_s
    end

    def log
      Rails.logger
    end

    def do_get(tind_search_params)
      uri = loggable_search_url(tind_search_params)
      log.debug("GET #{uri}")

      resp = RestClient.get(tind_search_url, params: tind_search_params)
      return resp.body if resp.code == 200

      log.error("GET #{uri} returned #{resp.code}: #{resp.body}")
      msg = "No TIND record found for p=#{tind_search_params[:p]}; TIND returned #{resp.code}"
      raise ActiveRecord::RecordNotFound, msg
    end

  end
end
