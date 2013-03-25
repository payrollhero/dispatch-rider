require 'spec_helper'

describe DispatchRider::QueueServices::Base do
  subject(:base_queue) do
    DispatchRider::QueueServices::Base.any_instance.stub(:assign_storage).and_return([])
    DispatchRider::QueueServices::Base.new
  end

  describe "#initialize" do
    it "should initiate a queue" do
      base_queue.queue.should eq([])
    end
  end

  describe "#push" do
    subject(:simple_queue) { DispatchRider::QueueServices::Simple.new }

    it "should push the serialized object to the queue" do
      simple_queue.push(DispatchRider::Message.new(:subject => "foo", :body => "bar"))
      result = JSON.parse(simple_queue.queue.first)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#insert" do
    it "should raise an exception" do
      expect { base_queue.insert(DispatchRider::Message.new(:subject => "foo", :body => "bar")) }.to raise_exception(NotImplementedError)
    end
  end

  describe "#pop" do
    subject(:simple_queue) { DispatchRider::QueueServices::Simple.new }

    before :each do
      simple_queue.queue.push(DispatchRider::Message.new(:subject => "foo", :body => "bar").to_json)
    end

    context "when the block passed to process the popped message returns true" do
      it "should return the first message in the queue" do
        simple_queue.pop {|msg| true}.should eq(DispatchRider::Message.new(:subject => 'foo', :body => 'bar'))
      end
    end

    context "when the block passed to process the popped message returns false" do
      it "should return the first message in the queue" do
        simple_queue.pop {|msg| false}.should eq(DispatchRider::Message.new(:subject => 'foo', :body => 'bar'))
      end

      it "should not remove the first message from the queue" do
        simple_queue.pop do |msg|
          msg.body = {:bar => "baz"}
          false
        end
        simple_queue.should_not be_empty
      end
    end

    context "when the queue is empty" do
      before :each do
        simple_queue.queue = []
      end

      it "should return nil" do
        simple_queue.pop do |msg|
          msg.body = {:bar => "baz"}
          true
        end.should be_nil
      end
    end
  end

  describe "#raw_head" do
    it "should raise an exception" do
      expect { base_queue.raw_head }.to raise_exception(NotImplementedError)
    end
  end

  describe "#construct_message_from" do
    it "should raise an exception" do
      expect { base_queue.construct_message_from({:subject => 'foo', :body => {:bar => 'baz'}}.to_json) }.to raise_exception(NotImplementedError)
    end
  end

  describe "#delete" do
    it "should raise an exception" do
      expect { base_queue.delete({:subject => 'foo', :body => {:bar => 'baz'}}.to_json) }.to raise_exception(NotImplementedError)
    end
  end

  describe "#empty?" do
    before :each do
      base_queue.stub!(:size).and_return { base_queue.queue.size }
    end

    context "when the queue is empty" do
      before :each do
        base_queue.queue = []
      end

      it "should return true" do
        base_queue.should be_empty
      end
    end

    context "when the queue is not empty" do
      before :each do
        base_queue.queue << {:subject => 'foo', :body => 'bar'}.to_json
      end

      it "should return false" do
        base_queue.should_not be_empty
      end
    end
  end

  describe "#size" do
    it "should raise an exception" do
      expect { base_queue.size }.to raise_exception(NotImplementedError)
    end
  end
end
