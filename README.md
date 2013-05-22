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

Sample Rails application rake task:

```ruby

    # lib/tasks/dispatch-rider
    namespace :"dispatch-rider" do
      desc "Tells DispatchRider to start running"
      task :run => [:"run:remote"]
  
      namespace :run do
        desc "Tells DispatchRider to start running"
        task :remote => [:ready, :set_aws_sqs_queue, :process]
  
        desc "Tells DispatchRider to start running (using the filesystem as the queue)"
        task :local => [:ready, :set_local_queue, :process]
  
        task :ready => :environment do
          puts "Creating subscriber..."
          @subscriber = DispatchRider::Subscriber.new
  
          [ # list of message handlers
            :read_news
          ].each do |handler_name|
            puts "Registering #{handler_name} handler..."
            @subscriber.register_handler(handler_name)
          end
        end
  
        task :set_aws_sqs_queue do
          queue_name = "news-updates-#{Rails.env}"
          puts "Setting AWS::SQS #{queue_name} queue..."
          @subscriber.register_queue(:aws_sqs, :name => queue_name)
          @subscriber.setup_demultiplexer(:aws_sqs)
        end
  
        task :set_local_queue do
          queue_path = "tmp/news-updates-#{Rails.env}"
          puts "Setting local filesystem queue @ #{queue_path.inspect}..."
          @subscriber.register_queue(:file_system, :path => queue_path)
          @subscriber.setup_demultiplexer(:file_system)
        end
  
        task :process do
          puts "Running..."
          @subscriber.process
        end
      end
    end

```

To run the subscriber simply execute following:

    $ bundle exec rake dispatch-rider:run

To run locally:

    $ bundle exec rake dispatch-rider:run:local

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
