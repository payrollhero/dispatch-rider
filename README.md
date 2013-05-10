# Dispatch::Rider

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'dispatch-rider'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch-rider

## Usage

# FileSystem Based publishing

```ruby
  publisher = DispatchRider::Publisher.new
  publisher.register_notification_service(:file_system)
  publisher.register_channel(:file_system, :foo, :path => "some/folder")
  publisher.publish(:service => :file_system, :to => :foo, :message => {:subject => "bar_handler", :body => {"bar" => "hola"}})
```

# SNS Based

  # For the publishing side
  publisher = DispatchRider::Publisher.new
  publisher.register_notification_service(:aws_sns)
  publisher.register_channel(:aws_sns, :foo)
  publisher.publish(:service => :aws_sns, :to => :foo, :message =>
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
