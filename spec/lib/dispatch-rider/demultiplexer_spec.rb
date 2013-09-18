require 'spec_helper'

describe DispatchRider::Demultiplexer, :nodb => true do
  class TestHandler < DispatchRider::Handlers::Base
    def process(options)
      raise "OMG!!!" if options["raise_exception"]
    end
  end

  let(:dispatcher) do
    dispatcher = DispatchRider::Dispatcher.new
    dispatcher.register(:test_handler)
    dispatcher
  end

  let(:queue) do
    DispatchRider::QueueServices::Simple.new
  end

  let(:message){ DispatchRider::Message.new(:subject => "test_handler", :body => {}) }

  let(:demultiplexer_thread) do
    demultiplexer
    thread = Thread.new do
      demultiplexer.start
    end
    thread[:demultiplexer] = demultiplexer
    thread
  end

  let(:error_handler){ ->(message, exception){ raise exception }}

  subject(:demultiplexer) { DispatchRider::Demultiplexer.new(queue, dispatcher, error_handler) }

  describe "#initialize" do
    it "should assign the queue" do
      demultiplexer.queue.should be_empty
    end

    it "should assign the dispatcher" do
      demultiplexer.dispatcher.fetch(:test_handler).should eq(TestHandler)
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
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end

      it "should call the correct handler" do
        TestHandler.any_instance.should_receive(:process).with(message.body)
        demultiplexer_thread.run
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
    end

    context "when the queue is empty" do
      it "should not be sending any message to the dispatcher" do
        demultiplexer.should_receive(:dispatch_message).exactly(0).times
        demultiplexer_thread.run
      end
    end

    context "when the handler crashes" do
      before do
        message.body = { "raise_exception" => true }
        queue.push message
      end

      it "should call the error handler" do
        error_handler.should_receive(:call).at_least(:once)
        demultiplexer_thread.run
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
    end

    context "when the queue crashes" do
      before do
        queue.stub(:pop){ raise "OMG!!!"}
      end

      it "should call the error handler" do
        error_handler.should_receive(:call).once
        demultiplexer_thread.run

        sleep 0.01 # give it a chance to process the job async before killing the demux
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

end
