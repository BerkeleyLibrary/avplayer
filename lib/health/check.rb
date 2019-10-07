module Health

  # Checks on the health of critical application dependencies
  #
  # @see https://tools.ietf.org/id/draft-inadarei-api-health-check-01.html JSON Format
  # @see https://www.consul.io/docs/agent/checks.html StatusCode based on Consul
  class Check

    TEST_PATRON_ID = '012158720'.freeze

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
      { 'tind:find_marc_record' => method(:try_tind_search) }
    end

    def passing?
      status == Status::PASS
    end

    def try_tind_search
      test_id = Tind::Id.new(field: '901m', value:'b23305522')
      Tind::find_marc_record(test_id)
      Result.pass
    rescue StandardError => e
      Result.warn(e.class.name)
    end

    def try_wowza_url
      test_collection = 'Pacifica'
      test_file = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'
      player_helper = Class.new { include PlayerHelper }.new
      stream_url = player_helper.wowza_url_for(collection: test_collection, file: test_file)
      resp = RestClient.head(stream_url)
      return Result.pass if resp.code == 200
      Result.warn("HEAD #{stream_url} returned #{resp.code}")
    rescue StandardError => e
      Result.warn(e.class.name)
    end

  end
end
