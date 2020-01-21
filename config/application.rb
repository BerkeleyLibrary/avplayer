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

    # Search URL for TIND metadata
    config.tind_base_uri = ENV.fetch('LIT_TIND_BASE_URL') do
      'https://digicoll.lib.berkeley.edu/'
    end

    # Search URL for Millennium metadata
    config.millennium_base_uri = ENV.fetch('LIT_MILLENNIUM_BASE_URL') do
      'http://oskicat.berkeley.edu/'
    end

    # Wowza server URL
    config.wowza_base_uri = ENV.fetch('LIT_WOWZA_BASE_URL') do
      'https://vm147.lib.berkeley.edu/'
    end

    # Video server URL
    # TODO: move video to Wowza
    config.video_base_uri = ENV.fetch('LIT_VIDEO_BASE_URL') do
      'http://www.lib.berkeley.edu/videosecret/'
    end

    # AV Player URL
    config.avplayer_base_uri = ENV.fetch('LIT_AVPLAYER_BASE_URL') do
      'https://avplayer.lib.berkeley.edu'
    end

    # ############################################################
    # Debugging

    # Display home page (defaults to false)
    config.show_homepage = ENV.fetch('LIT_SHOW_HOMEPAGE') do
      false
    end

    %i[tind_base_uri millennium_base_uri wowza_base_uri video_base_uri avplayer_base_uri show_homepage].each do |setting|
      config.logger.info("#{setting} = #{config.send(setting)}")
    end

  end
end
