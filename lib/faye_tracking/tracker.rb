module FayeTracking
  class Tracker
    def initialize(store)
      @store = store
    end

    def add(channel, user)
      @store.add(channel, user)
      @store.add(user, channel)
    end

    def remove(channel, user)
      @store.remove(channel, user)
      @store.remove(user, channel)
    end

    def channels_for_user(user)
      @store.members(user)
    end

    def users_in_channel(channel)
      @store.members(channel)
    end

    def user_in_channel?(user, channel)
      @store.member?(user, channel)
    end

    def channel_has_user?(channel, user)
      @store.member?(channel, user)
    end
  end
end
