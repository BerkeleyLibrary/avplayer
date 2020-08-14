# ------------------------------------------------------------
# CI

ENV['RAILS_ENV'] = 'test' if ENV['CI']

# ------------------------------------------------------------
# Rails

require File.expand_path('config/application', __dir__)
Rails.application.load_tasks

# ------------------------------------------------------------
# Defaults

# clear rspec/rails default :spec task in favor of :coverage
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
desc 'Run tests, check test coverage, check code style'
task default: %i[coverage rubocop]
