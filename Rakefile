# Add your own tasks in files placed in services/tasks ending in .rake,
# for example services/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = %w[--out test/reports/rubocop.txt]
end
