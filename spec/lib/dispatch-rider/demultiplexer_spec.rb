require 'spec_helper'

describe DispatchRider::Demultiplexer, :nodb => true do
  module TestHandler
    class << self
      def process(options)
        throw :bar if options["foo"]
      end
    end
  end

  let(:dispatcher) do
    dispatcher = DispatchRider::Dispatcher.new
    dispatcher.register(:test_handler)
  end

  let(:queue) do
    DispatchRider::QueueServices::Simple.new
  end

  let(:message){ DispatchRider::Message.new(:subject => "test_handler", :body => {"foo" => true}) }

  let(:demultiplexer_thread) do
    demultiplexer
    thread = Thread.new do
      demultiplexer.start
    end
    thread[:demultiplexer] = demultiplexer
    thread
  end

  subject(:demultiplexer) { DispatchRider::Demultiplexer.new(queue, dispatcher) }

  describe "#initialize" do
    it "should assign the queue" do
      demultiplexer.queue.should be_empty
    end

    it "should assign the dispatcher" do
      demultiplexer.dispatcher.handlers.should eq({:test_handler => TestHandler})
    end
  end

  describe "#start" do
    after do
      demultiplexer_thread[:demultiplexer].stop
      demultiplexer_thread.join
    end

    context "when the queue is not empty" do
      before do
        queue.push message
      end

      it "should be sending the message to the dispatcher" do
        demultiplexer.should_receive(:dispatch_message).with(message).at_least(:once)
        demultiplexer_thread.run
      end
    end

    context "when the queue is empty" do
      it "should not be sending any message to the dispatcher" do
        demultiplexer.should_receive(:dispatch_message).exactly(0).times
        demultiplexer_thread.run
      end
    end
  end

  describe ".stop" do
    it "should stop the demultiplexer" do
      demultiplexer_thread.run
      demultiplexer_thread.should be_alive # looper should be looping
      demultiplexer_thread[:demultiplexer].stop
      demultiplexer_thread.join
      demultiplexer_thread.should_not be_alive # looper should close the loop
    end
  end

  describe "#dispatch_message" do
    it "should call dispatcher to dispatch the message" do
      expect { demultiplexer.dispatch_message(message) }.to throw_symbol(:bar)
    end
  end
end
