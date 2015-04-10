# Dispatch::Rider

Dispatch rider is a pub/sub kind of library that allows you to publish a
message to a notification system (like Amazon SNS) and then you
can subscribe to the channels that you subscribed to and start
handling the messages.

### Build status

[![Build Status](https://travis-ci.org/payrollhero/dispatch-rider.png?branch=master)](https://travis-ci.org/payrollhero/dispatch-rider)
[![Code Climate](https://codeclimate.com/github/payrollhero/dispatch-rider.png)](https://codeclimate.com/github/payrollhero/dispatch-rider)
[![Dependency Status](https://gemnasium.com/payrollhero/dispatch-rider.png)](https://gemnasium.com/payrollhero/dispatch-rider)


## Installation

Add this line to your application's Gemfile:

    gem 'dispatch-rider'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch-rider

If you are using DispatchRider with rails, run the installer:

    $ rails generate dispatch_rider:install

## Usage

### Publisher

Setting up a publisher is simple.

### Hash Based Configuration

All configuration can be loaded from a hash instead of being done like the examples below.
(currently only implemented for the publisher)

#### Global configuration

You can set the global configuration using either a hash:

```ruby
DispatchRider::Publisher.configure({
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

or a block:

```ruby
DispatchRider::Publisher.configure do |config|
  config.parse({
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
end
```

Then anytime you call configure on a new publisher, it will default to global configuration.

```ruby
DispatchRider::Publisher.new

# is the same as

DispatchRider::Publisher.new(DispatchRider::Publisher.configuration)
```

#### Local configuration
Alternatively, you can create your own configuration and load that configuration into your new publisher.

```ruby
  config = DispatchRider::Publisher::Configuration.new({
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

  DispatchRider::Publisher.new(config)
```

You can load this configuration hash from a YAML file or something, whatever works
well for your environment.

#### The old way ...

To publish using the filesystem register the path where to publish the message files.

```ruby
publisher = DispatchRider::Publisher.new

publisher.register_notification_service(:file_system)
publisher.register_destination(:local_message_queue, :file_system, :dev_channel, :path => "tmp/news-updates")

publisher.publish(:destinations => :local_message_queue, :message => {
  :subject => "read_news",
  :body => {"headlines" => [
    "April 29, 2013: Rails 4.0.0.rc1 is released.",
    "May 14, 2013: Ruby 2.0.0-p195 is released"
  ]
}})
```

To publish using ```AWS::SNS``` make sure ```AWS.config``` has been setup.
It's then as easy as providing the configuration details of the topic to the publisher.

```ruby
publisher = DispatchRider::Publisher.new

publisher.register_notification_service(:aws_sns)
publisher.register_destination(:sns_message_queue, :aws_sns, :dev_channel, {
  :account => 777,
  :region  => 'us-east-1',
  :topic   => 'RoR'
})

publisher.publish(:destinations => :sns_message_queue, :message => {
  :subject => "read_news",
  :body => {"headlines" => [
    "April 29, 2013: Rails 4.0.0.rc1 is released.",
    "May 14, 2013: Ruby 2.0.0-p195 is released"
  ]
}})
```

To publish to multiple destinations:

```ruby
publisher.publish(:destinations => [:local_message_queue, :sns_message_queue], :message => {
  :subject => "read_news",
  :body => {"headlines" => [
    "April 29, 2013: Rails 4.0.0.rc1 is released.",
    "May 14, 2013: Ruby 2.0.0-p195 is released"
  ]
}})
```

Sample Rails publisher:

```ruby
# app/publishers/news_update
class NewsPublisher < DispatchRider::Publisher::Base

  destinations :sns_message_queue
  subject "read_news"

  def self.publish(news)
    new.publish({"headlines" => news.headlines})
  end

end

```

### Subscriber

### Configuration

You can configure the subscription side of DispatchRider by using the built in configuration object.

```ruby
DispatchRider.config do |config|
  config.before(:initialize) do
    # code to run before initialize
  end

  config.after(:process) do
    # code to run after process
  end

  # allows you to wrap a callback around the execution of each job
  config.around(:dispatch_message) do |job, message|
    some_block_around do
      job.call
    end
  end

  config.logger = Rails.logger
  config.default_retry_timeout = 300

  config.error_handler = DispatchRider::DefaultErrorHandler # an object that responds to .call(message, exception)

  config.queue_kind = :sqs
  config.queue_info = { name: "queue-production" }

  config.handler_path = Rails.root + "app/handlers" # path to handler files to be autoloaded
end
```

Options:

 * `logger` : what logger to use to send messages to (responds to the standard ruby Logger protocol), defaults to a new Logger sending messages to STDERR


### Callbacks

Dispatch rider supports injecting callbacks in a few parts of the
lifecycle of the process.

```
  :initialize       - when the runner is being initialized
  :process          - when the runner is running its event loop
  :dispatch_message - around the execution of a single message (the block is passed the job )
```

Each callback can have hooks plugged into it at `before`, `after` and `around` the execution.

### Manual Setup

To setup a subscriber you'll need message handlers. The handlers are named the same as the message subjects.
Each handler may also specify a retry_timeout as shown below.  When a job throws an exception it will be put back
on the queue in that time period if the queue supports timeouts.  If the underlying queue (such as filesystem) does
not support retry then this setting is ineffective.

Sample message handler:
```ruby
# app/handlers/bar_handler
class ReadNews < DispatchRider::Handlers::Base
  def process(message_body)
    message_body["headlines"].each do |headline|
      puts headline
    end
  end

  def retry_timeout
    10.minutes
  end
end
```

### Timeout & retry handling

If you have a long running job, or if you wish to retry a job later, you may use two methods in your
handler class.  return_to_queue and extend_timeout.

return_to_queue will retry your item immediately.
extend_timeout will tell the queue you wish to hold this item longer.

```ruby
# app/handlers/foo_handler
class LongRunning < DispatchRider::Handlers::Base
  def process(body)
    my_loop.each do |item|

      #... do some work ...
      extend_timeout(1.hour)
    end
  rescue OutOfResourcesImOutError
    return_to_queue #oops!  Better give this to somebody else!
  end
end
```

Sample subscriber setup:

```ruby
subscriber = DispatchRider::Subscriber.new

subscriber.register_queue(:aws_sqs, :name => "news-updates")
subscriber.register_handler(:read_news)
subscriber.setup_demultiplexer(:aws_sqs)

subscriber.process
```

Sample subscriber dispatch error handling (optional):

```ruby
# using objects

module ErrorHandler

  def self.call(message, exception)
    # put your error handling code here

    return false # or return true to permanently remove the message
  end

end

subscriber.setup_demultiplexer(kind, ErrorHandler)

# using lambdas

error_handler = ->(message, exception) do
  # put your error handling code here

  return false # or return true to permanently remove the message
end

subscriber.setup_demultiplexer(kind, error_handler)
```

#### Airbrake Support
Airbrake is supported out of the box. All you need to do is:

1. Install and configure the [airbrake gem](https://github.com/airbrake/airbrake).
2. Use the `DispatchRider::AirbrakeErrorHandler`.

```ruby
subscriber.setup_demultiplexer(kind, DispatchRider::AirbrakeErrorHandler)
```

or set it up in the config ...

```ruby
DispatchRider.config do |config|
  config.error_handler = DispatchRider::AirbrakeErrorHandler
end
```
## Deployment

In order to deploy a new version of the gem into the wild:


```bash
vim lib/dispatch-rider/version.rb
# set the new version
rake changelog
rake gemspec
# commit any changed files (should be only changelog, version and the gemspec)
# name your commit with the version number eg: "1.8.0"
rake release
# to push the gem to rubygems.org
```

## Contributing

### Process

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Licence

Copyright (c) 2015 PayrollHero Pte. Ltd.

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
