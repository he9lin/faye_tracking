require 'spec_helper'

describe FayeTracking do
  let(:client_id)         { 'abcdefg123456' }
  let(:another_client_id) { 'anotherclient' }

  before(:each) do
    FayeTracking.reset_store
  end

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

      it 'associate client_id with user' do
        faye_subscribe 'room', client_id, 'user_2'
        expect(described_class.user_with_client_id(client_id)).to eq('user_2')
      end
    end

    describe 'customize subscribe block' do
      it 'can set a customize subscribe block' do
        result = nil
        described_class.on_subscribe do |client_id, user_id, channel|
          result = [client_id, user_id, channel]
        end
        faye_subscribe 'room', client_id, 'user_1'
        expect(result).to eq([client_id, 'user_1', 'room'])
        described_class.reset_on_subscribe_callbacks
      end
    end
  end

  describe 'subscribing same user with different clientIds' do
    it 'user able to have multiple client ids' do
      faye_subscribe 'room', client_id, 'user_1'
      faye_subscribe 'room', another_client_id, 'user_1'
      expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy

      described_class.remove_from_channel 'room', client_id
      expect(described_class.user_in_channel?('user_1', 'room')).to be_truthy

      described_class.remove_from_channel 'room', another_client_id
      expect(described_class.user_in_channel?('user_1', 'room')).to be_falsey
    end
  end
end
