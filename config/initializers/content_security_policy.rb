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
  wowza_base = URI.parse(config.wowza_base_url)
  wowza_src = URI::HTTP.build(scheme: wowza_base.scheme, host: wowza_base.host, port: wowza_base.port)

  video_base = URI.parse(config.video_base_url)
  video_src = URI::HTTP.build(scheme: video_base.scheme, host: video_base.host, port: video_base.port)

  policy.default_src(
    :self,
    wowza_src.to_s,
    video_src.to_s,
    'https://cdn.jsdelivr.net',
    'https://p.typekit.net',
    'https://use.typekit.net',
    'data:',
    'blob:'
  )
end
