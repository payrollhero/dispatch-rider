require 'spec_helper'

describe DispatchRider::QueueServiceRegistrar do
  describe "#initialize" do
    it "should assign the empty que services container" do
      subject.queue_services.should eq({})
    end
  end

  describe "#register" do
    context "when the service requested is present" do
      it "should register the service by assigning a queue" do
        subject.register(:array_queue)
        subject.queue_services[:array_queue].queue.should eq([])
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
      subject.register(:array_queue)
    end

    it "should remove the registered queue service" do
      subject.unregister(:array_queue)
      subject.queue_services.should be_empty
    end
  end

  describe "#fetch" do
    context "when the queue service is registered" do
      before :each do
        subject.register(:array_queue)
      end

      it "should return the queue service" do
        subject.fetch(:array_queue).queue.should eq([])
      end
    end

    context "when the queue service is not registered" do
      it "should raise an exception" do
        expect { subject.fetch(:array_queue) }.to raise_exception(DispatchRider::QueueServiceNotRegistered)
      end
    end
  end
end
