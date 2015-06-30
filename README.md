# FayeTracking

A Faye extension for tracking user subscriptions, i.e. can be used for
checking if a user is online.

BUT: http://faye.jcoglan.com/ruby/monitoring.html

## Prerequisites

* Faye
* Redis

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faye_tracking'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faye_tracking

## Usage

Set it up:

```ruby
FayeTracking.configure do |config|
  config.redis = Redis.new
end

client.add_extension(FayeTracking.faye_extension)

FayeTracking.all_users_in_channel('/chat/1')
FayeTracking.user_in_any_channel?('/user_1')
FayeTracking.user_in_channel?('/user_1', '/chat/1')
```

Client side: a PrivatePub example using a fork here: https://github.com/he9lin/private_pub, which makes it possible to add client side Faye extensions to PrivatePub javascript.

```coffeescript
FayeTrackingExtension =
  outgoing: (message, callback) ->
    if message.channel == "/meta/subscribe"
      # Attach the user id to subscription messages
      subscription = PrivatePub.subscriptions[message.subscription]
      message.ext ?= {}
      message.ext.faye_tracking_client_id = subscription.user_id
    callback(message)

PrivatePub.extensions = [PrivatePubClientIdExtension]

# To subscribe to a channel
subscription["user_id"] = user_id
PrivatePub.sign(subscription)
PrivatePub.subscribe(subscription.channel, callback)
```

## Contributing

1. Fork it ( https://github.com/he9lin/faye_tracking/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
