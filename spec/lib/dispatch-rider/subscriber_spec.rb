require "spec_helper"

describe DispatchRider::Subscriber do
  module FooBar
    class << self
      def process(options)
        throw :process_was_called
      end
    end
  end

  describe "#initialize" do
    it "should assign a new queue service registrar" do
      subject.queue_service_registrar.store.should be_empty
    end
  end

  describe "#register_queue" do
    it "should register a queue service with the queue service registrar" do
      subject.register_queue(:simple)
      subject.queue_service_registrar.fetch(:simple).should be_empty
    end
  end

  describe "#register_handler" do
    it "should register a handler" do
      subject.register_handler(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol(:process_was_called)
    end
  end

  describe "#register_handlers" do
    it "should register all the handlers" do
      subject.register_handlers(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol(:process_was_called)
    end
  end

  describe "#setup_demultiplexer" do
    context "when a queue is registered" do
      before :each do
        subject.register_queue(:simple)
        subject.register_handler(:foo_bar)
      end

      it "should assign a demultiplexer" do
        subject.setup_demultiplexer(:simple)
        subject.demultiplexer.queue.should be_empty
        subject.demultiplexer.dispatcher.fetch(:foo_bar).should eq(FooBar)
      end
    end
  end

  describe "#process" do
    before :each do
      subject.register_queue(:simple)
      subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(:subject => :foo_bar, :body => {'baz' => 'blah'}))
      subject.register_handler(:foo_bar)
      subject.setup_demultiplexer(:simple)
    end

    it "should process the queue" do
      expect { subject.process }.to throw_symbol(:process_was_called)
    end
  end

end
