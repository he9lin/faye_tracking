module FayeTracking
  class RedisKeyList < AbstractKeyList
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

    def remove_all(key)
      @redis.del(key)
    end
  end
end
