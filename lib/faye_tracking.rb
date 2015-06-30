require 'redis'
require 'redis-namespace'
require 'logger'
require "faye_tracking/version"

module FayeTracking
  MAPPING_STORE_NAME = 'client_id_to_user'.freeze

  class << self
    attr_accessor :redis, :logger

    def configure(&block)
      block.call(self)
    end

    def reset_store
      raise 'redis is not set' unless redis
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
      @_tracker ||= begin
        key_list_store = RedisKeyList.new(redis)
        mapping_store  = RedisMapping.new(redis)
        Tracker.new(key_list_store, mapping_store)
      end
    end
  end
end

require "faye_tracking/faye_extension"
require "faye_tracking/store/abstract_key_list"
require "faye_tracking/store/abstract_mapping"
require "faye_tracking/store/adapter/redis_key_list"
require "faye_tracking/store/adapter/redis_mapping"
require "faye_tracking/tracker"
