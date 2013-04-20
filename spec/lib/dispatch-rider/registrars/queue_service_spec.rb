require 'spec_helper'

describe DispatchRider::Registrars::QueueService do
  describe "#initialize" do
    it "should assign the empty que services container" do
      subject.queue_services.should eq({})
    end
  end

  describe "#register" do
    context "when the service requested is present" do
      it "should register the service by assigning a queue" do
        subject.register(:simple)
        subject.queue_services[:simple].queue.should eq([])
      end
    end

    context "when the service requested is not present" do
      it "should raise an exception" do
        expect { subject.register(:redis_queue) }.to raise_exception(DispatchRider::QueueServiceNotFound)
      end
    end
  end

  describe "#unregister" do
    before :each do
      subject.register(:simple)
    end

    it "should remove the registered queue service" do
      subject.unregister(:simple)
      subject.queue_services.should be_empty
    end
  end

  describe "#fetch" do
    context "when the queue service is registered" do
      before :each do
        subject.register(:simple)
      end

      it "should return the queue service" do
        subject.fetch(:simple).queue.should eq([])
      end
    end

    context "when the queue service is not registered" do
      it "should raise an exception" do
        expect { subject.fetch(:simple) }.to raise_exception(DispatchRider::QueueServiceNotRegistered)
      end
    end
  end
end
