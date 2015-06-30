module FayeTracking
  class FayeExtension
    MONITORED_CHANNELS = [ '/meta/subscribe', '/meta/unsubscribe', '/meta/disconnect' ]

    def initialize(tracker)
      @tracker = tracker
    end

    def incoming(message, callback)
      return callback.call(message) unless MONITORED_CHANNELS.include? message['channel']

      FayeTracking.logger.debug "received incoming message: #{message}"

      unless message['error']
        subs_channel  = message['subscription']
        client_id     = message['clientId']
        app_client_id = message['ext']['faye_tracking_client_id']

        case message['channel']
        when '/meta/subscribe'
          @tracker.add_channel(subs_channel, app_client_id)
        when '/meta/disconnect'
          @tracker.remove_channel_by_client_id(subs_channel, app_client_id)
        end
      end

      callback.call(message)
    end
  end
end
