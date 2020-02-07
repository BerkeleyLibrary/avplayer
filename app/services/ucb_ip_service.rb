require 'ipaddr'
require 'restclient'

class UcbIpService

  # We basically trust the Framework campus networks page not to contain invalid numeric garbage
  IP_RANGE_RE = /\b((?:\d{1,3}\.){3}\d{1,3})-((?:\d{1,3}\.){3}\d{1,3})\b/.freeze

  # Internal ranges don't show up in the campus networks table
  AIRBEARS_RANGE = IPAddr.new('10.142.0.0/16').to_range
  SPLIT_TUNNEL_RANGE = IPAddr.new('10.136.0.0/16').to_range
  INTERNAL_RANGES = [SPLIT_TUNNEL_RANGE, AIRBEARS_RANGE].freeze

  class << self
    LOCALHOST = '127.0.0.1'.freeze

    # Determine whether the specified request is from a UCB IP.
    # @return true if to the best of our knowledge the specified request is from
    # a UCB IP address, or from localhost; false otherwise
    def ucb_request?(request)
      # Rails advice is usually to use ActionDispatch::Request.remote_ip, but
      # it's not reliable when you're running in a Docker container behind a
      # reverse proxy, so we need to rummage around in the headers
      headers = request.headers

      # This is usually going to be the reverse proxy but in development it might
      # be localhost (if you're running the app directly) or some Docker network
      # internal IP (if you're running with docker-compose). It's easy to special-
      # case the first, so we do; the second is harder, so we don't. Note also that
      # headers['action_dispatch.remote_ip'] is an ActionDispatch::RemoteIp::GetIp
      # object, not a string.
      remote_ip = headers['action_dispatch.remote_ip'].to_s
      return true if remote_ip == LOCALHOST

      # The real client IP (or the most real one we can get) will show up in
      # HTTP_X_FORWARDED_FOR, but so will the reverse proxy
      x_forwarded_for = headers['HTTP_X_FORWARDED_FOR']
      forwarded_addrs = (x_forwarded_for && x_forwarded_for.split(',').map(&:strip)) || []
      forwarded_addrs.any? { |addr| addr != remote_ip && service.campus_ip?(addr) }
    end

    private

    def service
      @service ||= UcbIpService.new
    end
  end

  def campus_ip?(addr)
    ipaddr = ipaddr_or_nil(addr)
    return false unless ipaddr

    in_any?(ipaddr, INTERNAL_RANGES) || in_any?(ipaddr, campus_network_ranges)
  end

  private

  def log
    Rails.logger
  end

  def campus_networks_uri
    Rails.application.config.campus_networks_uri
  end

  def in_any?(ipaddr, ranges)
    (ranges || []).any? { |r| r.include?(ipaddr) }
  end

  def campus_network_ranges
    @campus_network_ranges ||= [].tap do |ranges|
      campus_networks_data.scan(IP_RANGE_RE).each do |first, last|
        first_addr, last_addr = [first, last].map { |s| ipaddr_or_nil(s) }
        next unless first_addr && last_addr

        ranges << (first_addr..last_addr)
      end
    end
  rescue RestClient::Exception => e
    log.warn("Error loading IP ranges from #{campus_networks_uri}: #{e.message}")
    nil
  end

  def campus_networks_data
    uri = campus_networks_uri
    resp = RestClient.get(uri.to_s)
    return resp.body if resp.code == 200

    log.error("GET #{uri} returned #{resp.code}: #{resp.body || 'nil'}")
    raise(RestClient::RequestFailed.new(resp, resp.code).tap do |ex|
      ex.message = "No record found at #{uri}; host returned #{resp.code}"
    end)
  end

  def ipaddr_or_nil(addr)
    return addr if addr.is_a?(IPAddr)

    IPAddr.new(addr)
  rescue IPAddr::Error => e
    log.warn("Error parsing IP address #{addr.inspect}: #{e.message}")
    nil
  end

end
