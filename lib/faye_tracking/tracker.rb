module FayeTracking
  class Tracker
    def initialize(redis)
      @channel_to_client_ids = namespaced_key_list('channel_to_client_ids', redis)
      @client_id_to_channels = namespaced_key_list('client_id_to_channels', redis)
      @user_to_client_ids    = namespaced_key_list('user_to_client_ids',    redis)
      @client_id_to_users    = namespaced_key_list('client_id_to_users',    redis)
    end

    def add(channel, client_id, user)
      @channel_to_client_ids.add(channel, client_id)
      @client_id_to_channels.add(client_id, channel)
      @user_to_client_ids.add(user, client_id)
      @client_id_to_users.add(client_id, user)
    end

    def user_with_client_id(client_id)
      @client_id_to_users.members(client_id).first
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

    private

    def namespaced_key_list(name, redis)
      NamespacedKeyList.new(name, RedisKeyList.new(redis))
    end
  end
end
