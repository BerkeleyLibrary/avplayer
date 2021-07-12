source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'av_core', git: 'https://git.lib.berkeley.edu/lap/av_core.git'
gem 'browser', '~> 4.2'
gem 'jbuilder', '~> 2.7'
gem 'marc', '~> 1.0'
gem 'non-stupid-digest-assets', '~> 1.0' # Allow static pages (e.g. 404.html) to link to compiled assets
gem 'puma', '~> 5.2', '>= 5.2.2'
gem 'rails', '~> 6.1', '>= 6.1.3'
gem 'rest-client', '~> 2.1'
gem 'sass-rails', '~> 6'
gem 'typesafe_enum', '~> 0.2'
gem 'ucblit-logging', git: 'https://git.lib.berkeley.edu/lap/ucblit-logging.git'
gem 'webpacker', '~> 5.2'

gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 5.0'
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'debase', '0.2.5.beta2', require: false # workaround for https://youtrack.jetbrains.com/issue/RUBY-27575
  gem 'irb', require: false # workaround for https://github.com/bundler/bundler/issues/6929
  gem 'listen', '>= 3.0', '< 3.2'
  gem 'rubocop', '~> 1.18.0'
  gem 'rubocop-rails', '~> 2.9'
  gem 'rubocop-rspec', '~> 2.2'
  gem 'ruby-prof', '~> 1.4', require: false
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
