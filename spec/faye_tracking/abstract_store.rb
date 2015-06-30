module FayeTracking
  class AbstractStore
    def add(key, value)
      raise NotImplementedError
    end

    def remove(key, value)
      raise NotImplementedError
    end

    def member?(key, value)
      raise NotImplementedError
    end

    def members(key)
      raise NotImplementedError
    end

    def empty?(key)
      raise NotImplementedError
    end
  end
end
