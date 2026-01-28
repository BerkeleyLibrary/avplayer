# frozen_string_literal: true

# Health check configuration

OkComputer.logger = Rails.logger
OkComputer.check_in_parallel = true

ALMA_TEST_ID = 'b23305522'
TIND_TEST_ID = '(pacradio)01469'
WOWZA_TEST_COLL = 'Pacifica'
WOWZA_TEST_PATH = 'PRA_NHPRC1_AZ1084_00_000_00.mp3'

ALMA_TEST_URL = BerkeleyLibrary::AV::Metadata::Source::ALMA.marc_uri_for(ALMA_TEST_ID).to_s
WOWZA_TEST_URL = BerkeleyLibrary::AV::Track.hls_uri_for(collection: WOWZA_TEST_COLL, relative_path: WOWZA_TEST_PATH).to_s

class TindCheck < OkComputer::Check
  def check
    _ = BerkeleyLibrary::AV::Record.from_metadata(collection: WOWZA_TEST_COLL, record_id: TIND_TEST_ID)
    mark_message 'Authenticated TIND HTTP check successful'
  rescue BerkeleyLibrary::AV::RecordNotFound
    mark_failure
    mark_message("Authenticated TIND HTTP check failed: record #{TIND_TEST_ID} not found")
  rescue StandardError => e
    mark_failure
    mark_message("Authenticated TIND HTTP check failed: #{e}")
  end
end

class HeadCheck < OkComputer::HttpCheck
  def perform_request
    Timeout.timeout(request_timeout) do
      options = { read_timeout: request_timeout }

      if basic_auth_options.any?
        options[:http_basic_authentication] = basic_auth_options
      end

      RestClient.head(url.to_s, options)
    end
  rescue => e
    raise ConnectionFailed, e
  end
end

# Ensure Alma API is working.
OkComputer::Registry.register 'alma-metadata', HeadCheck.new(ALMA_TEST_URL)

# Ensure TIND API is working. This cannot use `OkComputer::HttpCheck`
# out of the box as we can't yet inject headers into the request without
# subclassing the whole thing.
OkComputer::Registry.register 'tind-metadata', TindCheck.new

# Ensure Wowza is working
OkComputer::Registry.register 'wowza-streaming', HeadCheck.new(WOWZA_TEST_URL)
