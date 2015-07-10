module FayeTracking
  class Tracker
    def initialize(redis)
      @channel_to_client_ids = NamespacedKeyList.new('channel_to_client_ids', RedisKeyList.new(redis))
      @client_id_to_channels = NamespacedKeyList.new('client_id_to_channels', RedisKeyList.new(redis))
      @user_to_client_ids    = NamespacedKeyList.new('user_to_client_ids',    RedisKeyList.new(redis))
      @client_id_to_users    = NamespacedKeyList.new('client_id_to_users',    RedisKeyList.new(redis))
    end

    def add(channel, client_id, user)
      @channel_to_client_ids.add(channel, client_id)
      @client_id_to_channels.add(client_id, channel)
      @user_to_client_ids.add(user, client_id)
      @client_id_to_users.add(client_id, user)
    end

    def remove(channel, client_id)
      @channel_to_client_ids.remove(channel, client_id)
      @client_id_to_channels.remove(client_id, channel)
      @client_id_to_users.members(client_id).each do |user|
        @user_to_client_ids.remove(user, client_id)
      end
      @client_id_to_users.remove_all(client_id)
    end

    def remove_all(client_id)
      @client_id_to_channels.members(client_id).each do |channel|
        @channel_to_client_ids.remove(channel, client_id)
      end
      @client_id_to_users.members(client_id).each do |user|
        @user_to_client_ids.remove(user, client_id)
      end
      @client_id_to_users.remove_all(client_id)
      @client_id_to_channels.remove_all(client_id)
    end

    def channels_for_user(user)
      client_ids = @user_to_client_ids.members(user)
      client_ids.inject([]) do |acc, client_id|
        acc += @client_id_to_channels.members(client_id)
      end.uniq
    end

    def users_in_channel(channel)
      client_ids = @channel_to_client_ids.members(channel)
      client_ids.inject([]) do |acc, client_id|
        acc += @client_id_to_users.members(client_id)
      end.uniq
    end

    def user_in_channel?(user, channel)
      client_ids = @user_to_client_ids.members(user)
      client_ids.any? do |client_id|
        @channel_to_client_ids.member? channel, client_id
      end
    end

    def channel_has_user?(channel, user)
      client_ids = @channel_to_client_ids.members(channel)
      client_ids.any? do |client_id|
        @user_to_client_ids.member? user, client_id
      end
    end
  end
end
