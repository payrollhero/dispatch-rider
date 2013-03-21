require "spec_helper"

describe DispatchRider::Runner do
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

    it "should assign a new dispatcher" do
      subject.dispatcher.handlers.should be_empty
    end
  end

  describe "#register_queue" do
    it "should register a queue service with the queue service registrar" do
      subject.register_queue(:array_queue)
      subject.queue_service_registrar.fetch(:array_queue).should be_empty
    end
  end

  describe "#register_handler" do
    it "should register a handler" do
      subject.register_handler(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol('bar')
    end
  end

  describe "#prepare" do
    before :each do
      subject.register_queue(:array_queue)
      subject.register_handler(:foo_bar)
    end

    context "when a queue and a handler are registered" do
      it "should assign a publisher" do
        subject.prepare(:array_queue)
        subject.publisher.queue.should be_empty
      end

      it "should assign a demultiplexer" do
        subject.prepare(:array_queue)
        subject.demultiplexer.queue.should be_empty
        subject.demultiplexer.dispatcher.handlers.should eq({:foo_bar => FooBar})
      end
    end
  end

  describe "#run" do
    before :each do
      subject.register_queue(:array_queue)
      subject.register_handler(:foo_bar)
      subject.prepare(:array_queue)
    end

    it "should be able to start the demultiplexer and process messages" do
      subject.publisher.publish(:subject => :foo_bar, :body => {'foo' => 'bar'})
      expect { subject.run }.to throw_symbol('bar')
    end
  end
end
