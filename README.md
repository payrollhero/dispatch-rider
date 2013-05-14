# Dispatch::Rider

Dispatch rider is a pub/sub kind of library that allows you to publish a
message to a notification system (like Amazon SNS) and then you
can subscribe to the channels that you subscribed to and start
handling the messages.
## Installation

Add this line to your application's Gemfile:

    gem 'dispatch-rider'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch-rider

## Usage

### Amazon SNS

```ruby
  # For the publishing side
  publisher = DispatchRider::Publisher.new
  publisher.register_notification_service(:aws_sns)
  publisher.register_destination(:sns_foo, :aws_sns, :foo, :account => 777,
:region => 'us-east-1', :topic => 'aliens') #
publisher.register_destination(<convinient unique name>, <notification
service registered>, <channel to publish to>, {:account => <SNS account
id>, :region => <amazon region>, :topic => <name of topic in SNS>})
  publisher.publish(:destinations => :sns_foo, :message =>
{:subject => "bar_handler", :body => {"bar" => "hola"}})

  # For the subscribing side
  module BarHandler
    class << self
      def process(options)
        throw :process_was_called
      end
    end
  end

  subscriber = DispatchRider::Subscriber.new
  subscriber.register_queue(:aws_sqs)
  subscriber.register_handler(:bar_handler)
  subscriber.setup_demultiplexer(:aws_sqs)
  subscriber.process
```

### File system based

```ruby
  publisher.register_notification_service(:file_system)
  publisher.register_destination(:file_foo, :file_system, :foo, :path => "some/folder")
  publisher.publish(:destinations => :file_foo, :message =>
{:subject => "bar_handler", :body => {"bar" => "hola"}})
```

### Multiple services

```ruby
  publisher.publish(:destinations => [:sns_foo, :file_foo], :message =>
{:subject => "bar_handler", :body => {"bar" => "hola"}})
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
