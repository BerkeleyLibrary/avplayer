source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby_version_file = File.expand_path('.ruby-version', __dir__)
ruby_version_exact = File.read(ruby_version_file).strip
ruby ruby_version_exact

gem 'berkeley_library-av-core', '~> 0.5.0'
gem 'berkeley_library-docker', '~> 0.2.0'
gem 'berkeley_library-logging', '~> 0.2'
gem 'browser', '~> 4.2'
gem 'jbuilder', '~> 2.13'
gem 'nokogiri', '~> 1.18'
# gem 'non-stupid-digest-assets', '~> 1.0' # Allow static pages (e.g. 404.html) to link to compiled assets
gem 'okcomputer', '~> 1.19'
gem 'omniauth-cas', '~> 2.0'
gem 'puma', '~> 5.3', '>= 5.3.1'
gem 'rails', '~> 8.0.4'
gem 'rest-client', '~> 2.1'
gem 'sassc-rails', '~> 2.1'
gem 'sprockets', '~> 4.0'
gem 'sprockets-rails', '~> 3.4', require: 'sprockets/railtie'
gem 'typesafe_enum', '~> 0.2'

group :development, :test do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'colorize'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 8.0'
end

group :development do
  gem 'listen', '>= 3.0'
  gem 'rubocop', '~> 1.81.7'
  gem 'rubocop-rails', '~> 2.34.2', require: false
  gem 'rubocop-rspec', '~> 3.8.0', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'ruby-prof', '~> 1.4', require: false
  gem 'web-console', '>= 4.1.0'
end

group :test do
  gem 'capybara'
  gem 'rspec', '~> 3.10'
  gem 'rspec_junit_formatter'
  # TODO: figure out Selenium under GitHub Actions
  # gem 'selenium-webdriver', '~> 4.0'
  gem 'simplecov', '~> 0.21', require: false
  gem 'simplecov-rcov', '~> 0.2', require: false
  gem 'webmock', require: false
end
