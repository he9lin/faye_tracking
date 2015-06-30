module FayeTracking
  class Tracker
    def initialize(key_list, mapping)
      @key_list = key_list
      @mapping = mapping
    end

    def add(channel, client_id, user)
      @mapping.set(client_id, user)
      @key_list.add(channel, user)
      @key_list.add(user, channel)
    end

    def remove(channel, client_id)
      if user = @mapping.get(client_id)
        @key_list.remove(channel, user)
        @key_list.remove(user, channel)
      end
    end

    def remove_user_from_all_channels(client_id)
      if user = @mapping.get(client_id)
        channels_for_user(user).each do |channel|
          @key_list.remove(channel, user)
        end
        @key_list.remove_all(user)
      end
    end

    def channels_for_user(user)
      @key_list.members(user)
    end

    def users_in_channel(channel)
      @key_list.members(channel)
    end

    def user_in_channel?(user, channel)
      @key_list.member?(user, channel)
    end

    def channel_has_user?(channel, user)
      @key_list.member?(channel, user)
    end
  end
end
