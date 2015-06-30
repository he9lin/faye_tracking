module FayeTracking
  class RedisStore < AbstractStore
    def initialize(redis)
      @redis = redis
    end

    def add(key, value)
      @redis.sadd key, value
    end

    def remove(key, value)
      @redis.srem key, value
    end

    def member?(key, value)
      @redis.sismember key, value
    end

    def members(key)
      @redis.smembers key
    end

    def empty?(key)
      @redis.smembers(key).empty?
    end
  end
end
