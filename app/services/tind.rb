require 'rest-client'

Dir.glob(File.expand_path('tind/*.rb', __dir__)).sort.each(&method(:require))

module Tind
  class << self

    # @param tind_id [Integer] the TIND id to look up
    # @return [MARC::Record, nil]
    def find_marc_record(tind_id)
      raise ArgumentError, "#{tind_id || 'nil'} is not an integer" unless tind_id.is_a?(Integer)
      raise 'tind_base_url not configured in Rails application' unless tind_base_url

      records = find_marc_records(tind_id)
      return unless records

      records.first
    rescue REXML::ParseException => e
      log.warn("find_marc_records(#{tind_id}) raised #{e.class}", e)
      nil
    end

    def tind_base_url
      Rails.application.config.tind_base_url
    end

    # @param tind_id [Integer] the TIND ID
    def marc_url_for(tind_id)
      raise ArgumentError, "#{tind_id || 'nil'} is not an integer" unless tind_id.is_a?(Integer)

      "#{tind_base_url}record/#{tind_id}/export/xm"
    end

    private

    # @return [Enumerable<MARC::Record>]
    def find_marc_records(tind_id)
      marc_xml = get_marc_xml(tind_id)
      input = StringIO.new(marc_xml)
      MARC::XMLReader.new(input) # MARC::XMLReader mixes in Enumerable
    end

    def get_marc_xml(tind_id)
      url = marc_url_for(tind_id)
      begin
        return do_get(url).scrub
      rescue RestClient::Exception => e
        log.error("GET #{url} returned #{e}", e)
        raise ActiveRecord::RecordNotFound, "No TIND record found for p=#{tind_id}; TIND returned #{e.http_code}"
      end
    end

    def log
      Rails.logger
    end

    def do_get(url)
      log.debug("GET #{url}")

      resp = RestClient.get(url)
      return resp.body if resp.code == 200

      log.error("GET #{url} returned #{resp.code}: #{resp.body}")
      msg = "No TIND record found at #{url}; TIND returned #{resp.code}"
      raise ActiveRecord::RecordNotFound, msg
    end

  end
end
