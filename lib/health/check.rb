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

    attr_reader :status
    attr_reader :details

    def initialize
      status = Status::PASS
      details = {}
      all_checks.each do |name, check_method|
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
      passing? ? 200 : 429
    end

    private

    def all_checks
      {
        TIND_CHECK => method(:try_tind_search),
        MILLENNIUM_CHECK => method(:try_millennium_search),
        WOWZA_CHECK => method(:try_wowza_url)
      }
    end

    def passing?
      status == Status::PASS
    end

    def try_millennium_search
      test_id = 'b23305522'
      marc_record = Millennium.find_marc_record(test_id)
      return Result.warn('Millennium record not found for ID: ' + test_id) unless marc_record

      Result.pass
    rescue StandardError => e
      Result.warn(e.class.name)
    end

    def try_tind_search
      test_id = 'b23305522'
      marc_record = Tind.find_marc_record(test_id)
      return Result.warn('TIND record not found for ID: ' + test_id) unless marc_record

      Result.pass
    rescue StandardError => e
      Result.warn(e.class.name)
    end

    def try_wowza_url
      av_file = AvFile.new(collection: 'Pacifica', path: 'PRA_NHPRC1_AZ1084_00_000_00.mp3')
      stream_url = av_file.streaming_url
      resp = RestClient.head(stream_url)
      return Result.pass if resp.code == 200 # OK

      Result.warn("HEAD #{stream_url} returned #{resp.code}")
    rescue StandardError => e
      Result.warn(e.class.name)
    end

  end
end
