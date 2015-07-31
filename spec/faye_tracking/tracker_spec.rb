require 'spec_helper'

describe FayeTracking::Tracker do
  let(:tracker)   { described_class.new(FayeTracking.redis) }
  let(:channel)   { 'room' }
  let(:client_id) { 'abcdefg123456' }
  let(:user_id)   { 'user_1' }

  before(:each) do
    FayeTracking.reset_store
  end

  describe '#remove' do
    before do
      tracker.add(channel, client_id, user_id)
      expect(tracker.users_in_channel(channel)).to_not be_empty
    end

    it 'removes a user from a channel' do
      tracker.remove channel, client_id
      expect(tracker.users_in_channel(channel)).to be_empty
    end

    it 'does not raise error when removing a non-existing user' do
      expect {
        tracker.remove channel, 'invalid_user'
      }.to_not raise_error
    end
  end
end
