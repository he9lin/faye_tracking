require 'spec_helper'

describe FayeTracking do
  before(:each) do
    FayeTracking.reset_store
  end

  def faye_run(meta_action, channel, user)
    message = {"channel" => meta_action, "ext" => {}}
    message["subscription"] = channel
    message["ext"]["faye_tracking_client_id"] = user
    FayeTracking.faye_extension.incoming(message, lambda { |m| m })
  end

  def faye_subscribe(channel, user)
    faye_run('/meta/subscribe', channel, user)
  end

  def faye_disconnect(channel, user)
    faye_run('/meta/disconnect', channel, user)
  end

  context 'subscribing to a channel' do
    before do
      faye_subscribe 'room', 'user_1'
    end

    it 'adds user to the subscription channel' do
      expect(described_class.user_in_any_channel?('user_1')).to be_truthy
      expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy
      expect(described_class.user_in_channel?('user_2', 'room')).to be_falsey
    end

    it 'returns all users in a channel' do
      faye_subscribe 'room', 'user_2'
      expect(described_class.all_users_in_channel('room')).to match_array(['user_1', 'user_2'])
    end
  end

  context 'disconnecting to a channel' do
    before do
      faye_subscribe 'room', 'user_1'
    end

    it 'removes a user from a subscription channel' do
      faye_disconnect 'room', 'user_1'
      expect(described_class.user_in_any_channel?('user_1')).to be_falsey
      expect(described_class.all_users_in_channel('rooom')).to eq([])

      faye_subscribe  'room', 'user_2'
      expect(described_class.user_in_any_channel?('user_2')).to be_truthy
    end

    it 'does not raise error when removing a non-existing user' do
      expect {
        faye_disconnect 'room', 'user_2'
      }.to_not raise_error
    end
  end
end
