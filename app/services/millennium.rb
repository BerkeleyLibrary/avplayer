require 'rest-client'

Dir.glob(File.expand_path('millennium/*.rb', __dir__)).sort.each(&method(:require))

module Millennium

  class << self

    def find_marc_record(bib_number)
      uri = marc_uri_for(bib_number)
      html = do_get(uri)
      MarcExtractor.new(html).extract_marc_record
    rescue RestClient::Exception => e
      log.error("GET #{uri} returned #{e}, e")
      raise ActiveRecord::RecordNotFound, "No Millennium record found for bib #{bib_number}; Millennium returned #{e.http_code}"
    rescue StandardError => e
      log.error("Unable to parse MARC from body returned by GET #{uri}", e)
      raise ActiveRecord::RecordNotFound, "No Millennium record found for bib #{bib_number}: #{e}"
    end

    def millennium_search_url
      Rails.application.config.millennium_search_url
    end

    private

    def log
      Rails.logger
    end

    def marc_uri_for(bib_number)
      "#{millennium_search_url}?/.#{bib_number}/.#{bib_number}/1%2C1%2C1%2CB/marc~#{bib_number}"
    end

    def do_get(uri)
      log.debug("GET #{uri}")
      resp = RestClient.get(uri)
      if resp.code != 200
        log.error("GET #{uri} returned #{resp.code}: #{resp.body}")
        raise ActiveRecord::RecordNotFound, "No Millennium record found for bib #{bib_number}; Millennium returned #{resp.code}"
      end
      resp.body
    end
  end
end
