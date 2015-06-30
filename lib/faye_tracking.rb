require 'redis'
require 'redis-namespace'
require 'logger'
require "faye_tracking/version"

module FayeTracking
  class << self
    attr_accessor :redis, :logger

    def configure(&block)
      block.call(self)
    end

    def reset_store
      redis.keys('*').each {|k| redis.del k}
    end

    def faye_extension
      @_faye_extension ||= FayeExtension.new(tracker)
    end

    def user_in_any_channel?(user)
      !tracker.channels_for_user(user).empty?
    end

    def user_in_channel?(user, channel)
      tracker.user_in_channel?(user, channel)
    end

    def all_users_in_channel(channel)
      tracker.users_in_channel(channel)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private

    def tracker
      raise 'redis is not set' unless redis
      @_tracker ||= Tracker.new(RedisStore.new(redis))
    end
  end
end

require "faye_tracking/faye_extension"
require "faye_tracking/abstract_store"
require "faye_tracking/redis_store"
require "faye_tracking/tracker"
