# Dispatch::Rider

Dispatch rider is a pub/sub kind of library that allows you to publish a
message to a notification system (like Amazon SNS) and then you
can subscribe to the channels that you subscribed to and start
handling the messages.

### Build status

[![Build Status](https://travis-ci.org/payrollhero/dispatch-rider.png)](https://travis-ci.org/payrollhero/dispatch-rider)

## Installation

Add this line to your application's Gemfile:

    gem 'dispatch-rider'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch-rider

## Usage

### Hash Based Configuration

All configuration can be loaded from a hash instead of being done like the examples below.
(currently only implemented for the publisher)

eg:

```ruby
  publisher = DispatchRider::Publisher.new
  publisher.configure({
    notification_services: {
      file_system: {}
    },
    destinations: {
      file_foo: {
        service: :file_system,
        channel: :foo,
        options: {
          path: "test/channel",
        }
      }
    }
  })
```

You can load this configuration hash from a YAML file or something, whatever works
well for your environment.

### Amazon SNS

```ruby
  # For the publishing side
  publisher = DispatchRider::Publisher.new
  publisher.register_notification_service(:aws_sns)
  publisher.register_destination(:sns_foo, :aws_sns, :foo, :account => 777, :region => 'us-east-1', :topic => 'aliens')
  publisher.publish(:destinations => :sns_foo, :message => {:subject => "bar_handler", :body => {"bar" => "hola"}})

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

### Process

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Licence

Copyright (c) 2013 Suman Mukherjee

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
