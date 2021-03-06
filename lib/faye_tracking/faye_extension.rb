module FayeTracking
  class FayeExtension
    MONITORED_CHANNELS = [
      '/meta/subscribe',
      '/meta/unsubscribe',
      '/meta/disconnect'
    ]

    def initialize(tracker)
      @tracker = tracker
    end

    def incoming(message, callback)
      return callback.call(message) \
        unless MONITORED_CHANNELS.include? message['channel']

      FayeTracking.logger.debug "received incoming message: #{message}"

      unless message['error']
        subs_channel = message['subscription']
        client_id    = message['clientId']
        run_subscribe_callbacks = false

        case message['channel']
        when '/meta/subscribe'
          ext = message['ext']
          if app_client_id = ext['faye_tracking_client_id']
            @tracker.add(subs_channel, client_id, app_client_id)
            run_subscribe_callbacks = true
          else
            error_message = "missing ext['faye_tracking_client_id']"
            FayeTracking.logger.error "error with message: #{error_message}"
            message['error'] = error_message
          end
        when '/meta/unsubscribe'
          # This is not reliable, more robust way to detect unsubscribe event.
          # see: http://faye.jcoglan.com/ruby/monitoring.html
        end
      end

      callback.call(message)

      if run_subscribe_callbacks
        FayeTracking.run_on_subscribe_callbacks(
          client_id, app_client_id, subs_channel
        )
      end
    end
  end
end
