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
    config.tind_url_base = 'https://digicoll.lib.berkeley.edu/'

    # Search URL for Millennium metadata (see app/services/millennium)
    config.millennium_search_url = 'http://oskicat.berkeley.edu/search~S1'

    # Wowza server URL
    config.wowza_base_url = 'http://vm147.lib.berkeley.edu:1935/'

    # Video server URL
    # TODO: move video to Wowza
    config.video_base_url = 'http://www.lib.berkeley.edu/videosecret/'
  end
end
