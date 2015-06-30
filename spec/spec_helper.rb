$LOAD_PATH.unshift File.expand_path(File.join File.dirname(__FILE__), '..', 'lib')

require 'faye_tracking'

FayeTracking.configure do |config|
  config.redis = Redis::Namespace.new(:faye_tracking_test, redis: Redis.new)
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
