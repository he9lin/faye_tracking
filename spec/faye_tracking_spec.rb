require 'spec_helper'

describe FayeTracking do
  before(:each) do
    FayeTracking.reset_store
  end

  let(:client_id)         { 'rpy799jnfeq' }
  let(:another_client_id) { '651w533ncba' }

  def faye_run(meta_action, subscription, client_id, user)
    # {"channel"=>"/meta/subscribe", "clientId"=>"rpy799jnfeqxi651w533nc5sxxmwanf", "subscription"=>"/companies/1", "id"=>"3", "ext"=>{"private_pub_signature"=>"6856c32ee576322163928717ec9288d570185830", "private_pub_timestamp"=>1435689757199, "faye_tracking_client_id"=>"3"}}
    # {"channel"=>"/meta/disconnect", "clientId"=>"rpy799jnfeqxi651w533nc5sxxmwanf", "id"=>"5"}

    subscription = opts["subscription"]
    client_id    = opts["client_id"]
    user         = opts["user"]

    message = { "channel"  => meta_action, "clientId" => client_id }
    message["subscription"] = subscription if subscription
    message["ext"] = { "faye_tracking_client_id" => user }

    FayeTracking.faye_extension.incoming(message, lambda { |m| m })
  end

  def faye_subscribe(channel, client_id, user)
    faye_run('/meta/subscribe', client_id, channel, user)
  end

  def faye_disconnect(channel, client_id, user)
    faye_run('/meta/disconnect', client_id, channel, user)
  end

  context 'subscribing to a channel' do
    before do
      faye_subscribe 'room', client_id, 'user_1'
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
      faye_disconnect 'room', client_id
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
