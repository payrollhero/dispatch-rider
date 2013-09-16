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

### Publisher

Setting up a publisher is simple.

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
class NewsPublisher
  @publisher = DispatchRider::Publisher.new

  amazon_config = YAML.load_file("#{Rails.root}/config/amazon.yml")

  @publisher.register_notification_service(:aws_sns)
  @publisher.register_destination(:sns_message_queue, :aws_sns, :dev_channel, {
    :account => amazon_config[:account],
    :region  => amazon_config[:region],
    :topic   => "news-updates-#{Rails.env}"
  })

  @destinations = [:sns_message_queue]

  class << self
    attr_reader :publisher
    attr_accessor :destinations
  end

  delegate :publisher, :destinations, :to => :"self.class"

  def initialize(news)
    @news = news
  end

  def publish
    publisher.publish(:destinations => destinations, :message => {
      :subject => "read_news",
      :body => {"headlines" => @news.headlines}
    })
  end
end

# app/models/news
class News
  serialize :headlines, Array

  after_create :publish

  def publish
     NewsPublisher.new(self).publish
  end
end

News.create!(:headlines => [
  "April 29, 2013: Rails 4.0.0.rc1 is released.",
  "May 14, 2013: Ruby 2.0.0-p195 is released"
])
```

### Subscriber

To setup a subscriber you'll need message handlers. The handlers are named the same as the message subjects.

Sample message handler:
```ruby
# app/handlers/bar_handler
module ReadNews
  class << self
    def process(message_body)
      message_body["headlines"].each do |headline|
        puts headline
      end
    end
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
2. Use the `AirbrakeErrorHandler`.

```ruby
subscriber.setup_demultiplexer(kind, AirbrakeErrorHandler)
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
