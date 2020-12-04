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

    require 'lib_it/logging'
    LibIT::Logging.configure!

    # ############################################################
    # External services

    # Search URL for TIND metadata
    config.tind_base_uri = ENV.fetch('LIT_TIND_BASE_URL', 'https://digicoll.lib.berkeley.edu/') # production
    # config.tind_base_uri = ENV.fetch('LIT_TIND_BASE_URL', 'https://berkeley-test.tind.io/') # test

    # Search URL for Millennium metadata
    config.millennium_base_uri = ENV.fetch('LIT_MILLENNIUM_BASE_URL', 'http://oskicat.berkeley.edu/')

    # Wowza server URL
    config.wowza_base_uri = ENV.fetch('LIT_WOWZA_BASE_URL', 'https://wowza.lib.berkeley.edu/')

    # AV Player URL
    config.avplayer_base_uri = ENV.fetch('LIT_AVPLAYER_BASE_URL', 'https://avplayer.lib.berkeley.edu/') # production
    # config.avplayer_base_uri = ENV.fetch('LIT_AVPLAYER_BASE_URL', 'https://avplayer-staging.swarm-ewh-staging.devlib.berkeley.edu/') # staging

    # Campus networks URL
    # Note that this includes LBNL, and that's intentional
    config.campus_networks_uri = ENV.fetch('CAMPUS_NETWORKS_URL', 'https://framework.lib.berkeley.edu/campus-networks/')

    # Display home page (defaults to false)
    config.show_homepage = ENV.fetch('LIT_SHOW_HOMEPAGE', false)

    # Allow direct track previews (defaults to false)
    config.allow_preview = ENV.fetch('LIT_ALLOW_PREVIEW', false)

    %i[
      tind_base_uri
      millennium_base_uri
      wowza_base_uri
      avplayer_base_uri
      campus_networks_uri
      show_homepage
    ].each do |setting|
      config.logger.info("#{setting} = #{config.send(setting)}")
    end

  end
end
