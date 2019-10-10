require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

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

    require 'av_player/logger.rb'
    config.logger = AvPlayer::Logger.new($stdout)
    config.lograge.enabled = true
    config.lograge.custom_options = ->(event) do
      {
        time: Time.now,
        request_id: event.payload[:headers].env['action_dispatch.request_id'],
        remote_ip: event.payload[:headers][:REMOTE_ADDR]
      }
    end
    config.lograge.formatter = Class.new do |fmt|
      def fmt.call(data)
        { msg: 'Request', request: data }
      end
    end

    unless (env = Rails.env) && env.production?
      readable_logger = Ougai::Logger.new("log/#{env}.log")
      readable_logger.formatter = Ougai::Formatters::Readable.new
      config.logger.extend Ougai::Logger.broadcast(readable_logger)
    end

    # ############################################################
    # External services

    # Search URL for TIND metadata (see app/services/tind)
    config.tind_search_url = 'https://digicoll.lib.berkeley.edu/search'

    # Wowza server URL
    config.wowza_base_url = 'http://vm147.lib.berkeley.edu:1935/'

    # Video server URL
    # TODO: move video to Wowza
    config.video_base_url = 'http://www.lib.berkeley.edu/videosecret/'
  end
end
