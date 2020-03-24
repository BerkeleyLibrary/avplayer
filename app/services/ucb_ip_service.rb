require 'ipaddr'
require 'restclient'

class UcbIpService

  # We basically trust the Framework campus networks page not to contain invalid numeric garbage
  IP_RANGE_RE = /\b((?:\d{1,3}\.){3}\d{1,3})-((?:\d{1,3}\.){3}\d{1,3})\b/.freeze

  # Internal ranges don't show up in the campus networks table
  AIRBEARS_RANGE = IPAddr.new('10.142.0.0/16').to_range
  SPLIT_TUNNEL_RANGE = IPAddr.new('10.136.0.0/16').to_range
  ALLOWED_INTERNAL_RANGES = [SPLIT_TUNNEL_RANGE, AIRBEARS_RANGE].freeze

  # These ranges are our internal infrastructure and if they show up in
  # remote_ip or X-Forwarded-For we shouldn't trust them
  LIBRARY_VM_RANGE = IPAddr.new('128.32.10.0/24').to_range
  INGRESS_RANGE = IPAddr.new('10.255.0.0/16').to_range
  INVALID_INTERNAL_RANGES = [LIBRARY_VM_RANGE, INGRESS_RANGE].freeze

  # EZProxy is a special case of the Library VM range
  EZPROXY_RANGE = IPAddr.new('128.32.10.230')..IPAddr.new('128.32.10.233')

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

      # This is sometimes the real remote IP, sometimes the reverse proxy.
      # Note that headers['action_dispatch.remote_ip'] is not a string but
      # an ActionDispatch::RemoteIp::GetIp object, not a string.
      remote_ip = headers['action_dispatch.remote_ip'].to_s
      return true if ucb_address?(remote_ip)

      # The real client IP (or the most real one we can get) will show up in
      # HTTP_X_FORWARDED_FOR, but so will the reverse proxy
      x_forwarded_for = headers['HTTP_X_FORWARDED_FOR']
      forwarded_addrs = (x_forwarded_for && x_forwarded_for.split(',').map(&:strip)) || []
      forwarded_addrs.any? { |addr| ucb_address?(addr) }
    end

    private

    def ucb_address?(addr)
      return true if addr == LOCALHOST
      return false if service.invalid_internal?(addr)

      service.campus_ip?(addr)
    end

    def service
      @service ||= UcbIpService.new
    end
  end

  def campus_ip?(addr)
    ipaddr = ipaddr_or_nil(addr)
    return false unless ipaddr

    in_any?(ipaddr, ALLOWED_INTERNAL_RANGES) || in_any?(ipaddr, campus_network_ranges)
  end

  def invalid_internal?(addr)
    ipaddr = ipaddr_or_nil(addr)
    return false unless ipaddr
    return false if EZPROXY_RANGE.include?(ipaddr)

    in_any?(addr, INVALID_INTERNAL_RANGES)
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
