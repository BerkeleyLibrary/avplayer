source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'av_core', git: 'https://git.lib.berkeley.edu/lap/av_core.git'
gem 'amazing_print', '~> 1.1'
gem 'jbuilder', '~> 2.7'
gem 'lograge', '~> 0.11'
gem 'marc', '~> 1.0'
gem 'non-stupid-digest-assets', '~> 1.0' # Allow static pages (e.g. 404.html) to link to compiled assets
gem 'ougai', '~> 1.8'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0', '>= 6.0.2.2'
gem 'rest-client', '~> 2.1'
gem 'sass-rails', '~> 6'
gem 'typesafe_enum', '~> 0.2'
gem 'webpacker', '~> 4.0'

gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'rspec-rails', '~> 3.9'
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'irb', require: false # workaroundfor https://github.com/bundler/bundler/issues/6929
  gem 'listen', '>= 3.0', '< 3.2'
  gem 'rubocop', '~> 0.74.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'ci_reporter_rspec'
  gem 'rspec-support'
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.18', require: false
  gem 'simplecov-rcov', require: false

  # Alpine Linux doesn't get along with webdrivers (https://github.com/titusfortner/webdrivers/issues/78),
  # so we use Rack::Test instead of the Rails 6 default Selenium/Chrome. If/as/when we need JavaScript
  # testing, we can try to find a more permanent solutino.
  #
  # gem 'webdrivers'
end
