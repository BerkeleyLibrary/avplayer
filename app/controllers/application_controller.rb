class ApplicationController < ActionController::Base

  before_action :log_request_ips

  def log
    Rails.logger
  end

  def log_request_ips
    headers = request.headers
    request_info = {
      ip: request.ip,
      remote_ip: request.remote_ip,

      remote_addr: headers['REMOTE_ADDR'],
      x_forwarded_for: headers['HTTP_X_FORWARDED_FOR'],

      # yes, RFC 2616 uses a variant spelling for 'referrer', it's a known issue
      # https://tools.ietf.org/html/rfc2616#section-14.36
      referer: headers['HTTP_REFERER'],
      turbolinks_referrer: headers['HTTP_TURBOLINKS_REFERRER']
    }
    log.debug(controller_request: request_info)
  end
end
