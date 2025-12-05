require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module AvPlayer
  class Application < Rails::Application

    APP_SETTINGS_KEYS = %i[campus_networks_uri show_homepage allow_preview cas_host].freeze

    # ############################################################
    # RAILS DEFAULTS

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    #
    # We exclude `av_player` because an initializer to loads it. Otherwise,
    # autoloading blows up with a NameError for AvPlayer::TrackExtensions.
    config.autoload_lib(ignore: %w[assets tasks av_player])

    # ############################################################
    # Application settings

    # Campus networks URL
    # Note that this includes LBNL, and that's intentional
    config.campus_networks_uri = ENV.fetch('CAMPUS_NETWORKS_URL', 'https://framework.lib.berkeley.edu/campus-networks/')

    # Display home page (defaults to false)
    config.show_homepage = ENV.fetch('LIT_SHOW_HOMEPAGE', false)

    # Allow direct track previews (defaults to false)
    config.allow_preview = ENV.fetch('LIT_ALLOW_PREVIEW', false)

    # TODO: configure this more elegantly and make it play better with Selenium tests
    config.cas_host = ENV.fetch('CAS_HOST') do
      "auth#{'-test' unless Rails.env.production?}.berkeley.edu"
    end

    # ############################################################
    # AV::Config settings

    # Search URL for TIND metadata
    config.tind_base_uri = ENV.fetch('LIT_TIND_BASE_URL', 'https://digicoll.lib.berkeley.edu/') # production
    # config.tind_base_uri = ENV.fetch('LIT_TIND_BASE_URL', 'https://berkeley-test.tind.io/') # test

    # Wowza server URL
    config.wowza_base_uri = ENV.fetch('LIT_WOWZA_BASE_URL', 'https://wowza.lib.berkeley.edu/')
    # config.wowza_base_uri = ENV.fetch('LIT_WOWZA_BASE_URL', 'https://wowza.ucblib.org/') # staging

    # AV Player URL
    config.avplayer_base_uri = ENV.fetch('LIT_AVPLAYER_BASE_URL', 'https://avplayer.lib.berkeley.edu/') # production
    # config.avplayer_base_uri = ENV.fetch('LIT_AVPLAYER_BASE_URL', 'https://avplayer.ucblib.org') # staging

    # Alma SRU hostname
    config.alma_sru_host = ENV.fetch('LIT_ALMA_SRU_HOST', 'berkeley.alma.exlibrisgroup.com')

    # Alma institution code
    config.alma_institution_code = ENV.fetch('LIT_ALMA_INSTITUTION_CODE', '01UCS_BER')

    # Alma Primo host
    config.alma_primo_host = ENV.fetch('LIT_ALMA_PRIMO_HOST', 'search.library.berkeley.edu')

    # Alma view state key to use when generating Alma permalinks
    config.alma_permalink_key = ENV.fetch('LIT_ALMA_PERMALINK_KEY', 'iqob43')

    # ############################################################
    # Log configuration

    config.after_initialize do
      AvPlayer::BuildInfo.log_to(Rails.logger)

      app_settings = APP_SETTINGS_KEYS.to_h { |attr| [attr, Rails.application.config.send(attr)] }
      Rails.logger.info("#{AvPlayer::Application} settings:", settings: app_settings)

      BerkeleyLibrary::AV::Config.log_settings!(to_logger: Rails.logger)
    rescue StandardError => e
      Rails.logger.error('Error logging build & config info', e)
    end

  end
end
