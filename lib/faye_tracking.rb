require 'redis'
require 'redis-namespace'
require 'logger'
require "faye_tracking/version"

module FayeTracking
  class << self
    attr_accessor :logger
    attr_writer :redis

    def configure(&block)
      block.call(self)
    end

    def user_in_any_channel?(user)
      !tracker.channels_for_user(user).empty?
    end

    def user_in_channel?(user, channel)
      tracker.user_in_channel?(user, channel)
    end

    def users_in_channel(channel)
      tracker.users_in_channel(channel)
    end

    def reset_store
      redis.keys('*').each {|k| redis.del k}
    end

    def faye_extension
      @_faye_extension ||= FayeExtension.new(tracker)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def redis
      @redis || raise('redis is not set')
    end

    def tracker
      @_tracker = Tracker.new(redis)
    end
  end
end

require "faye_tracking/faye_extension"
require "faye_tracking/tracker"
require "faye_tracking/store/abstract_key_list"
require "faye_tracking/store/adapter/redis_key_list"
require "faye_tracking/store/adapter/namespaced_key_list"
