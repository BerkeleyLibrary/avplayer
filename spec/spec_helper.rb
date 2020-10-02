# ------------------------------------------------------------
# Rails

if (env = ENV['RAILS_ENV'])
  abort("Can't run tests in environment #{env}") if env != 'test'
else
  ENV['RAILS_ENV'] = 'test'
end

# ------------------------------------------------------------
# Dependencies

require 'colorize'
require 'webmock/rspec'

require 'simplecov' if ENV['COVERAGE']

# ------------------------------------------------------------
# RSpec configuration

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
  config.before(:each) { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after(:each) { WebMock.allow_net_connect! }

  # Required for shared contexts (e.g. in ssh_helper.rb); see
  # https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context#background
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # System tests
  # cf. https://medium.com/table-xi/a-quick-guide-to-rails-system-tests-in-rspec-b6e9e8a8b5f6
  config.before(:each, type: :system) do
    # Alpine Linux doesn't get along with webdrivers (https://github.com/titusfortner/webdrivers/issues/78),
    # so we use Rack::Test instead of the Rails 6 default Selenium/Chrome. If/as/when we need JavaScript
    # testing, we can try to find a more permanent solutino.
    driven_by :rack_test, using: :rack_test
  end

  # AVPlayer configuration, or rather deconfiguration
  config.before(:each) do
    attrs = %w[avplayer_base_uri millennium_base_uri tind_base_uri wowza_base_uri]
    attrs.each { |attr| AV::Config.instance_variable_set("@#{attr}", nil) }
  end
end
