require "spec_helper"

describe DispatchRider::Reactor do
  module FooBar
    class << self
      def process(options)
        throw options['foo'] if options.fetch('foo')
      end
    end
  end

  describe "#initialize" do
    it "should assign a new queue service registrar" do
      subject.queue_service_registrar.queue_services.should be_empty
    end
  end

  describe "#register_queue" do
    it "should register a queue service with the queue service registrar" do
      subject.register_queue(:regular_queue)
      subject.queue_service_registrar.fetch(:regular_queue).should be_empty
    end
  end

  describe "#register_handler" do
    it "should register a handler" do
      subject.register_handler(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol('bar')
    end
  end

  describe "#register_handlers" do
    it "should register all the handlers" do
      subject.register_handlers(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol('bar')
    end
  end

  describe "#setup_demultiplexer" do
    context "when a queue is registered" do
      before :each do
        subject.register_queue(:regular_queue)
      end

      it "should assign a demultiplexer" do
        subject.register_handler(:foo_bar)
        subject.setup_demultiplexer(:regular_queue)
        subject.demultiplexer.queue.should be_empty
        subject.demultiplexer.dispatcher.handlers.should eq({:foo_bar => FooBar})
      end
    end
  end

  describe "#setup_publisher" do
    before :each do
      subject.register_queue(:regular_queue)
    end

    context "when a queue is registered" do
      it "should assign a publisher" do
        subject.setup_publisher(:regular_queue)
        subject.publisher.queue.should be_empty
      end
    end
  end

  describe "#process" do
    before :each do
      subject.register_queue(:regular_queue)
      subject.setup_publisher(:regular_queue)
      subject.register_handler(:foo_bar)
      subject.setup_demultiplexer(:regular_queue)
    end

    it "should be able to start the demultiplexer and process messages" do
      subject.publisher.publish(:subject => :foo_bar, :body => {'foo' => 'bar'})
      expect { subject.process }.to throw_symbol('bar')
    end
  end
end
