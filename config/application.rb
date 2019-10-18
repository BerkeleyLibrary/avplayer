require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

require_relative '../lib/docker'
Docker::Secret.setup_environment!

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AvPlayer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # ############################################################
    # Customize logging

    require 'av_player/logging.rb'
    AvPlayer::Logging.configure(config)

    # ############################################################
    # External services

    # Search URL for TIND metadata (see app/services/tind)
    config.tind_base_url = ENV.fetch('LIT_TIND_BASE_URL') do
      'https://digicoll.lib.berkeley.edu/'
    end

    # Search URL for Millennium metadata (see app/services/millennium)
    config.millennium_search_url = ENV.fetch('LIT_MILLENNIUM_SEARCH_URL') do
      'http://oskicat.berkeley.edu/search~S1'
    end

    # Wowza server URL
    config.wowza_base_url = ENV.fetch('LIT_WOWZA_BASE_URL') do
      'http://vm147.lib.berkeley.edu:1935/'
    end

    # Video server URL
    # TODO: move video to Wowza
    config.video_base_url = ENV.fetch('LIT_VIDEO_BASE_URL') do
      'http://www.lib.berkeley.edu/videosecret/'
    end

    # ############################################################
    # Content security

    config.content_security_policy do |policy|
      wowza_base = URI.parse(config.wowza_base_url)
      wowza_src = URI::HTTP.build(scheme: wowza_base.scheme, host: wowza_base.host, port: wowza_base.port)

      video_base = URI.parse(config.video_base_url)
      video_src = URI::HTTP.build(scheme: video_base.scheme, host: video_base.host, port: video_base.port)

      policy.default_src(:self)
      policy.style_src(:self, 'https://cdn.jsdelivr.net', 'https://fonts.googleapis.com')
      policy.script_src(:self, 'https://cdn.jsdelivr.net')
      policy.font_src(:self, 'https://fonts.gstatic.com')
      policy.img_src(:self, 'https://cdn.jsdelivr.net', 'data:')
      policy.media_src(wowza_src.to_s, video_src.to_s, 'blob:')
      policy.connect_src(wowza_src.to_s, video_src.to_s)
    end
  end
end
