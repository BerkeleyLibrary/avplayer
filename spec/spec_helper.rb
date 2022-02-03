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
    AV::Config.send(:clear!) if defined?(AV::Config)
  end
end

# ------------------------------------------------------------
# Utility methods

# TODO: use BerkeleyLibrary::Alma for this stuff

def sru_url_base
  'https://berkeley.alma.exlibrisgroup.com/view/sru/01UCS_BER?version=1.2&operation=searchRetrieve&query='
end

def permalink_base
  'https://search.library.berkeley.edu/permalink/01UCS_BER/iqob43/alma'
end

def alma_sru_url_for(record_id)
  return "#{sru_url_base}alma.mms_id%3D#{record_id}" unless AV::RecordId::Type.for_id(record_id) == AV::RecordId::Type::MILLENNIUM

  full_bib = AV::RecordId.ensure_check_digit(record_id)
  "#{sru_url_base}alma.other_system_number%3DUCB-#{full_bib}-01ucs_ber"
end

def alma_sru_data_path_for(record_id)
  "spec/data/alma/#{record_id}-sru.xml"
end

def stub_sru_request(record_id, body: nil)
  sru_url = alma_sru_url_for(record_id)
  stub_request(:get, sru_url).to_return(status: 200, body: body || File.new(alma_sru_data_path_for(record_id)))
end

def alma_marc_record_for(record_id)
  marc_xml_path = alma_sru_data_path_for(record_id)
  MARC::XMLReader.new(marc_xml_path).first
end
