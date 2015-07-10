module FayeTracking
  class NamespacedKeyList < AbstractKeyList
    def initialize(ns, key_list)
      raise ArgumentError, 'namespace param cannot be blank' if ns.nil? || ns.empty?
      
      @ns       = ns
      @key_list = key_list
    end

    def add(key, value)
      @key_list.add build_key(key), value
    end

    def remove(key, value)
      @key_list.remove build_key(key), value
    end

    def member?(key, value)
      @key_list.member? build_key(key), value
    end

    def members(key)
      @key_list.members build_key(key)
    end

    def empty?(key)
      @key_list.empty? build_key(key)
    end

    def remove_all(key)
      @key_list.remove_all build_key(key)
    end

    private

    def build_key(key)
      [@ns, key].join(':')
    end
  end
end
