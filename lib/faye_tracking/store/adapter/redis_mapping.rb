module FayeTracking
  class RedisMapping < AbstractMapping
    def initialize(redis, name=FayeTracking::MAPPING_STORE_NAME)
      @name = name
      @redis = redis
    end

    def set(key, value)
      @redis.hset @name, key, value
    end

    def get(key)
      @redis.hget @name, key
    end

    def delete(key)
      @redis.del @name, key
    end
  end
end
