module FayeTracking
  class FayeExtension
    MONITORED_CHANNELS = [ '/meta/subscribe', '/meta/disconnect' ]

    def initialize(tracker)
      @tracker = tracker
    end

    def incoming(message, callback)
      return callback.call(message) unless MONITORED_CHANNELS.include? message['channel']

      unless message['error']
        subs_channel  = message['subscription']
        app_client_id = message['ext']['faye_tracking_client_id']

        case message['channel']
        when '/meta/subscribe'
          @tracker.add(subs_channel, app_client_id)
        when '/meta/disconnect'
          @tracker.remove(subs_channel, app_client_id)
        end
      end

      callback.call(message)
    end
  end
end
