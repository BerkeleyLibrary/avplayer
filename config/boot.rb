ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Load Docker secrets from /run/secrets into ENV
require 'berkeley_library/docker'
BerkeleyLibrary::Docker::Secret.load_secrets!
