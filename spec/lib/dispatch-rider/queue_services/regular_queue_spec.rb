require 'spec_helper'

describe DispatchRider::QueueServices::RegularQueue do
  describe "#assign_storage" do
    it "should return an empty array" do
      subject.assign_storage({}).should be_a Queue
    end
  end

  describe "#enqueue" do
    it "should push a serialized object into the queue" do
      subject.enqueue({'subject' => 'foo', 'body' => 'bar'}.to_json)
      result = JSON.parse(subject.queue.pop)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#dequeue" do
    before :each do
      subject.enqueue({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the first item from the queue" do
      result = JSON.parse(subject.dequeue)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#dequeue" do
    let(:item_in_queue){ {'subject' => 'foo', 'body' => 'bar'}.to_json }

    before :each do
      subject.enqueue(item_in_queue)
    end

    it "should remove the item from the queue" do
      subject.dequeue
      subject.queue.should be_empty
    end
  end

  describe "#size" do
    before :each do
      subject.enqueue({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the size of the queue" do
      subject.size.should eq(1)
    end
  end
end
