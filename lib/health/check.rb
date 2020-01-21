require_relative 'result'

module Health

  # Checks on the health of critical application dependencies
  #
  # @see https://tools.ietf.org/id/draft-inadarei-api-health-check-01.html JSON Format
  # @see https://www.consul.io/docs/agent/checks.html StatusCode based on Consul
  class Check

    # TODO: use Typesafe::Enum
    TIND_CHECK = 'TIND'.freeze
    WOWZA_CHECK = 'Wowza'.freeze
    MILLENNIUM_CHECK = 'Millennium'.freeze

    TEST_BIB_NUMBER = 'b23305522'.freeze
    TEST_TIND_ID = '21178'
    TEST_WOWZA_COLLECTION = 'Pacifica'.freeze
    TEST_WOWZA_PATH = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'.freeze

    attr_reader :status
    attr_reader :details

    def initialize
      status = Status::PASS
      details = {}
      Check.all_checks.each do |name, check_method|
        result = check_method.call
        details[name] = result.as_json
        status &= result.status
      end

      @status = status
      @details = details
    end

    def as_json(*)
      { status: status, details: details }
    end

    def http_status_code
      status.http_status_code
    end

    class << self
      def all_checks
        {
          MILLENNIUM_CHECK => method(:try_millennium),
          TIND_CHECK => method(:try_tind),
          WOWZA_CHECK => method(:try_wowza)
        }
      end

      private

      def try_millennium
        service_uri = AV::Metadata::Source::MILLENNIUM.marc_uri_for(TEST_BIB_NUMBER)
        make_head_request(service_uri)
      end

      def try_tind
        service_uri = AV::Metadata::Source::TIND.marc_uri_for(TEST_TIND_ID)
        make_head_request(service_uri)
      end

      def try_wowza
        service_uri = AV::Track.streaming_uri_for(collection: Check::TEST_WOWZA_COLLECTION, relative_path: Check::TEST_WOWZA_PATH)
        make_head_request(service_uri)
      end

      def make_head_request(url)
        # TODO: use an HTTP client library that can handle URIs
        resp = RestClient.head(url.to_s)
        return Result.pass if resp.code == 200 # OK

        Result.warn("HEAD #{url} returned #{resp.code}")
      rescue StandardError => e
        log.warn(e)
        Result.warn(e.class.name)
      end

      def log
        Rails.logger
      end
    end

  end
end
