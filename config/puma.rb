# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count).to_i
threads min_threads_count, max_threads_count

# Bind to all interfaces (0.0.0.0) in all environments, not just production.
bind ENV.fetch('PUMA_BINDING', 'tcp://0.0.0.0:3000')

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# @note(danschmidt5189) You'll see this referred to as "WEB_CONCURRENCY" in
# Heroku articles, but we use 'PUMA_WORKERS' in all our rails apps because
# it's more descriptive (literally, the number of worker processes).
workers ENV.fetch('PUMA_WORKERS', 2).to_i

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

log_formatter do |str|
  Rails.logger.formatter.call(Logger::INFO, Time.zone.now, nil, str)
end
