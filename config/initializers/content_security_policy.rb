# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self, :https
#   policy.font_src    :self, :https, :data
#   policy.img_src     :self, :https, :data
#   policy.object_src  :none
#   policy.script_src  :self, :https
#   policy.style_src   :self, :https
#   # If you are using webpack-dev-server then specify webpack-dev-server host
#   policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

#   # Specify URI for violation reports
#   # policy.report_uri "/csp-violation-report-endpoint"
# end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

Rails.application.config.content_security_policy do |policy|
  config = Rails.application.config

  wowza_base = URI.parse(config.wowza_base_uri)
  wowza_alt = case wowza_base.scheme
              when 'http'
                URI::HTTPS.build(host: wowza_base.host)
              when 'https'
                URI::HTTP.build(host: wowza_base.host)
              else
                raise "Unsupported scheme for Wowza base URI #{wowza_base}"
              end

  wowza_host_ezproxy = "#{wowza_base.host.gsub('.', '-')}.libproxy.berkeley.edu"
  wowza_src_ezproxy = URI::HTTPS.build(host: wowza_host_ezproxy)

  wowza_host_ezproxy_stg = "#{wowza_base.host.gsub('.', '-')}.libproxy-staging.berkeley.edu"
  wowza_src_ezproxy_stg = URI::HTTPS.build(host: wowza_host_ezproxy_stg)

  policy.default_src(
    :self,
    :unsafe_inline,
    wowza_base.to_s,
    wowza_alt.to_s,
    wowza_src_ezproxy.to_s,
    wowza_src_ezproxy_stg.to_s,
    # TODO: fewer CDNs?
    'https://cdn.jsdelivr.net',
    'https://cdn.dashjs.org',
    'https://p.typekit.net',
    'https://use.typekit.net',
    'data:',
    'blob:'
  )
end
