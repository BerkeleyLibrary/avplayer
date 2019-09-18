source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

gem 'jbuilder', '~> 2.7'
gem 'marc', '~> 1.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0.0'
gem 'rest-client', '~> 2.1'
gem 'sass-rails', '~> 5'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'rspec-rails'
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'irb', require: false # workaroundfor https://github.com/bundler/bundler/issues/6929
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', '~> 0.74.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'ci_reporter_rspec'
  gem 'rspec-support'
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-rcov', require: false
  gem 'webdrivers'
end
