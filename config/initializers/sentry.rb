# frozen_string_literal: true

logger = ::Logger.new('log/raven.log')
logger.level = ::Logger::DEBUG

Raven.configure do |config|
  config.logger = logger
  config.dsn = ENV['SENTRY_DSN']
  config.environments = %w(staging production)
end
