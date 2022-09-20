# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Demultiplexer, nodb: true do
  class TestHandler < DispatchRider::Handlers::Base
    def process(options)
      raise "OMG!!!" if options["raise_exception"]
    end
  end

  subject(:demultiplexer) { DispatchRider::Demultiplexer.new(queue, dispatcher, error_handler) }

  let(:dispatcher) do
    dispatcher = DispatchRider::Dispatcher.new
    dispatcher.register(:test_handler)
    dispatcher
  end

  let(:queue) do
    DispatchRider::QueueServices::Simple.new
  end

  let(:message) { DispatchRider::Message.new(subject: "test_handler", body: {}) }

  let(:demultiplexer_thread) do
    demultiplexer
    thread = Thread.new do
      demultiplexer.start
    end
    thread[:demultiplexer] = demultiplexer
    thread
  end

  let(:error_handler) { ->(_message, exception) { raise exception } }

  describe "#initialize" do
    it "should assign the queue" do
      expect(demultiplexer.queue).to be_empty
    end

    it "should assign the dispatcher" do
      expect(demultiplexer.dispatcher.fetch(:test_handler)).to eq(TestHandler)
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
        expect(demultiplexer).to receive(:dispatch_message).with(message).at_least(:once)
        demultiplexer_thread.run
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
      # THIS ALSO TESTS THAT THE JOB IS NOT RUN MULTIPLE TIMES
      # IF THIS FAILS, BE CAREFUL NOT TO INTRODUCE BUGS
      it "should call the correct handler" do
        expect_any_instance_of(TestHandler).to receive(:process).with(message.body).at_least(1).times
        demultiplexer_thread.run
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
    end

    context "when the queue is empty" do
      it "should not be sending any message to the dispatcher" do
        expect(demultiplexer).to receive(:dispatch_message).exactly(0).times
        demultiplexer_thread.run
      end
    end

    context "when the handler crashes" do
      before do
        message.body = { "raise_exception" => true }
        queue.push message
      end

      it "should call the error handler" do
        expect(error_handler).to receive(:call).at_least(:once).and_return(true)
        expect(queue).not_to receive(:delete)
        demultiplexer_thread.run
        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
    end

    context "when the queue crashes" do
      before do
        allow(queue).to receive(:pop) { raise "OMG!!!" }
      end

      it "should call the error handler" do
        expect(error_handler).to receive(:call).once
        demultiplexer_thread.run

        sleep 0.01 # give it a chance to process the job async before killing the demux
      end
    end
  end

  describe ".stop" do
    it "should stop the demultiplexer" do
      demultiplexer_thread.run
      expect(demultiplexer_thread).to be_alive # looper should be looping
      demultiplexer_thread[:demultiplexer].stop
      demultiplexer_thread.join
      expect(demultiplexer_thread).not_to be_alive # looper should close the loop
    end
  end

end
