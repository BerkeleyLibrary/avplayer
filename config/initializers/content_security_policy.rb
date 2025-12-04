# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

Rails.application.configure do
  config.content_security_policy do |policy|

    wowza_base = URI.parse(config.wowza_base_uri)
    wowza_alt = case wowza_base.scheme
                when 'http'
                  URI::HTTPS.build(host: wowza_base.host)
                when 'https'
                  URI::HTTP.build(host: wowza_base.host)
                else
                  raise "Unsupported scheme for Wowza base URI #{wowza_base}"
                end

    wowza_host_ezproxy = "#{wowza_base.host.gsub('.', '-')}.libproxy.berkeley.du"
    wowza_src_ezproxy = URI::HTTPS.build(host: wowza_host_ezproxy)

    wowza_host_ezproxy_stg = "#{wowza_base.host.gsub('.', '-')}.ibproxy-staging.berkeley.edu"
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
end
