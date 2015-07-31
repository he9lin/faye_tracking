require 'spec_helper'

describe FayeTracking do
  before(:each) do
    FayeTracking.reset_store
  end

  let(:client_id)         { 'rpy799jnfeq' }
  let(:another_client_id) { '651w533ncba' }

  def faye_run(meta_action, subscription, client_id, user)
    message = { "channel"  => meta_action, "clientId" => client_id }
    message["subscription"] = subscription                 if subscription
    message["ext"] = { "faye_tracking_client_id" => user } if user

    FayeTracking.faye_extension.incoming(message, lambda { |m| m })
  end

  def faye_subscribe(channel, client_id, user)
    faye_run('/meta/subscribe', channel, client_id, user)
  end

  def faye_unsubscribe(channel, client_id)
    faye_run('/meta/unsubscribe', channel, client_id, nil)
  end

  def faye_disconnect(client_id)
    faye_run('/meta/disconnect', nil, client_id, nil)
  end

  describe 'subscribing to a channel' do
    describe 'multiple users' do
      before do
        faye_subscribe 'room', client_id, 'user_1'
      end

      it 'adds user to the subscription channel' do
        expect(described_class.user_in_any_channel?('user_1')).to be_truthy
        expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy
        expect(described_class.user_in_channel?('user_2', 'room')).to be_falsey
      end

      it 'returns all users in a channel' do
        faye_subscribe 'room', client_id, 'user_2'
        expect(described_class.users_in_channel('room')).to \
          match_array(['user_1', 'user_2'])
      end
    end

    describe 'customize subscribe block' do
      it 'can set a customize subscribe block' do
        result = nil
        FayeTracking.on_subscribe do |client_id, user_id, channel|
          result = [client_id, user_id, channel]
        end
        faye_subscribe 'room', client_id, 'user_1'
        expect(result).to eq([client_id, 'user_1', 'room'])
      end
    end
  end

  context 'unsubscribing a channel' do
    before do
      faye_subscribe 'room', client_id, 'user_1'
    end

    it 'removes a user from a subscription channel' do
      faye_unsubscribe 'room', client_id
      expect(described_class.user_in_any_channel?('user_1')).to be_falsey
      expect(described_class.users_in_channel('rooom')).to eq([])

      faye_subscribe  'room', client_id, 'user_2'
      expect(described_class.user_in_any_channel?('user_2')).to be_truthy
    end

    it 'does not raise error when removing a non-existing user' do
      expect {
        faye_unsubscribe 'room', 'user_2'
      }.to_not raise_error
    end
  end

  describe 'subscribing/unsubscribing same users with different clientIds' do
    before do
      faye_subscribe 'room', client_id, 'user_1'
      faye_subscribe 'room', another_client_id, 'user_1'
    end

    it 'user able to have multiple client ids' do
      expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy

      faye_unsubscribe 'room', client_id
      expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy

      faye_unsubscribe 'room', another_client_id
      expect(described_class.user_in_channel?('user_1', 'room')).to be_falsey
    end
  end

  context 'disconnecting' do
    before do
      faye_subscribe 'room1', client_id, 'user_1'
      faye_subscribe 'room2', client_id, 'user_1'
      faye_subscribe 'room1', another_client_id, 'user_2'
    end

    it 'removes the user from all channels' do
      faye_disconnect(client_id)
      expect(described_class.user_in_any_channel?('user_1')).to be_falsey
      expect(described_class.users_in_channel('room1')).to eq(['user_2'])
    end
  end
end
