require 'spec_helper'

describe DispatchRider::Demultiplexer, :nodb => true do
  let(:queue) do
    DispatchRider::QueueServices::ArrayQueue.new
  end
  let(:queued_message){ DispatchRider::Message.new(:subject => "do_something", :body => "some_text") }
  let(:demultiplexer) { DispatchRider::Demultiplexer.new(queue) }
  let(:demultiplexer_thread) do
    demultiplexer
    thread = Thread.new do
      demultiplexer.start
    end
    thread[:demultiplexer] = demultiplexer
    thread
  end

  describe ".start" do
    after do
      demultiplexer_thread[:demultiplexer].stop
      demultiplexer_thread.join
    end

    context "when the queue is not empty" do
      before do
        queue.push queued_message
      end

      it "should be sending the message to the dispatcher" do
        demultiplexer.should_receive(:dispatch_message).with(queued_message).at_least(:once)
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
      DispatchRider::Dispatcher.should_receive(:dispatch).with(queued_message)
      demultiplexer.send(:dispatch_message, queued_message)
    end
  end
end
