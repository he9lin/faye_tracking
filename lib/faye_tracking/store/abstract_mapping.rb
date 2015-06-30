module FayeTracking
  class AbstractMapping
    def set(key, value)
      raise NotImplementedError
    end

    def get(key)
      raise NotImplementedError
    end

    def delete(key)
      raise NotImplementedError
    end
  end
end
