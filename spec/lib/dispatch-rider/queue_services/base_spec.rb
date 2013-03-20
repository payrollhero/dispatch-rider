require 'spec_helper'

describe DispatchRider::QueueServices::Base do
  describe "#initialize" do
    it "should initiate a queue" do
      DispatchRider::QueueServices::Base.any_instance.should_receive(:assign_storage).with({}).and_return([])
      subject.queue.should eq([])
    end
  end

  describe "#assign_storage" do
    it "should raise an exception" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end

  describe "#push" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    end

    it "should push the serialized object to the queue" do
      subject.should_receive(:enqueue).and_return { |msg| subject.queue << msg }
      subject.push(DispatchRider::Message.new(:subject => "foo", :body => "bar"))
      result = JSON.parse(subject.queue.first)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#enqueue" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    end

    it "should raise an exception" do
      expect { subject.enqueue(DispatchRider::Message.new(:subject => "foo", :body => "bar")) }.to raise_exception(NotImplementedError)
    end
  end

  describe "#pop" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
      subject.queue.push(DispatchRider::Message.new(:subject => "foo", :body => "bar").to_json)
      subject.stub!(:get_head).and_return { subject.queue.first }
      subject.stub!(:dequeue).and_return { subject.queue.shift }
    end

    context "when the block passed to process the popped message returns true" do
      it "should return the first message in the queue" do
        subject.pop {|msg| true}.should eq(DispatchRider::Message.new(:subject => 'foo', :body => 'bar'))
      end

      it "should remove the first message from the queue" do
        subject.pop do |msg|
          msg.body = {:bar => "baz"}
          true
        end
        subject.queue.should be_empty
      end
    end

    context "when the block passed to process the popped message returns false" do
      it "should return the first message in the queue" do
        subject.pop {|msg| false}.should eq(DispatchRider::Message.new(:subject => 'foo', :body => 'bar'))
      end

      it "should not remove the first message from the queue" do
        subject.pop do |msg|
          msg.body = {:bar => "baz"}
          false
        end
        subject.queue.should_not be_empty
      end
    end

    context "when the queue is empty" do
      before :each do
        subject.queue = []
      end

      it "should return nil" do
        subject.pop do |msg|
          msg.body = {:bar => "baz"}
          true
        end.should be_nil
      end
    end
  end

  describe "#get_head" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    end

    it "should raise an exception" do
      expect { subject.get_head }.to raise_exception(NotImplementedError)
    end
  end

  describe "#dequeue" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    end

    it "should raise an exception" do
      expect { subject.dequeue }.to raise_exception(NotImplementedError)
    end
  end

  describe "#empty?" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
      subject.stub!(:size).and_return { subject.queue.size }
    end

    context "when the queue is empty" do
      before :each do
        subject.queue = []
      end

      it "should return true" do
        subject.should be_empty
      end
    end

    context "when the queue is not empty" do
      before :each do
        subject.queue << {:subject => 'foo', :body => 'bar'}.to_json
      end

      it "should return false" do
        subject.should_not be_empty
      end
    end
  end

  describe "#size" do
    before :each do
      DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    end

    it "should raise an exception" do
      expect { subject.size }.to raise_exception(NotImplementedError)
    end
  end
end
