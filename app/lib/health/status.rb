require 'typesafe_enum'

module Health
  # Enumerated list of health states
  class Status < TypesafeEnum::Base
    # NOTE: states should be ordered from least to most severe

    # OK
    new :PASS, 200

    # Failure should probably be 503 Service Unavailable, but Zenoss only distinguishes between
    # response classes (2xx/3xx/4xx/5xx). To get Zenoss to report health check failures differently
    # from 500 Internal Server Error etc., we use 429 Too Many Requests.
    new :WARN, 429

    # Concatenates health states, returning the more severe state.
    # @return [Status] the more severe status
    def &(other)
      return self unless other

      self >= other ? self : other
    end

    # The name of the status
    # @return [String] the name of the status
    def name
      key.to_s
    end

    # The HTTP status code that should be returned for the status
    # @return [Integer] the HTTP status code
    def http_status_code
      # noinspection RubyYardReturnMatch
      value
    end

    # Returns the status as a string, suitable for use as a JSON value.
    # @return [String] the name of the status, in lower case
    def as_json(*)
      name.downcase
    end

  end
end
