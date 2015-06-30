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

```ruby
FayeTracking.configure do |config|
  config.redis = Redis.new
end

FayeTracking.all_users_in_channel('/chat/1')
FayeTracking.user_in_any_channel?('/user_1')
FayeTracking.user_in_channel?('/user_1', '/chat/1')

client.add_extension(FayeTracking.faye_extension)
```

## Contributing

1. Fork it ( https://github.com/he9lin/faye_tracking/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
