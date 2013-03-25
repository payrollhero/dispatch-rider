require 'spec_helper'

describe DispatchRider::QueueServices::Simple do
  subject(:simple_queue) do
    DispatchRider::QueueServices::Simple.new
  end

  describe "#assign_storage" do
    it "should return an empty array" do
      simple_queue.assign_storage({}).should eq([])
    end
  end

  describe "#insert" do
    it "should insert a serialized object into the queue" do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
      result = JSON.parse(simple_queue.queue.pop)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#raw_head" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the first item from the queue" do
      result = JSON.parse(simple_queue.raw_head)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#construct_message_from" do
    context "when the item is not nil" do
      it "should return the item casted as a message" do
        result = simple_queue.construct_message_from({'subject' => 'foo', 'body' => 'bar'}.to_json)
        result.subject.should eq('foo')
        result.body.should eq('bar')
      end
    end

    context "when the item is nil" do
      it "should return nil" do
        simple_queue.construct_message_from(nil).should be_nil
      end
    end
  end

  describe "#delete" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should remove the item from the queue" do
      simple_queue.delete({'subject' => 'foo', 'body' => 'bar'}.to_json)
      simple_queue.should be_empty
    end
  end

  describe "#size" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the size of the queue" do
      simple_queue.size.should eq(1)
    end
  end
end
