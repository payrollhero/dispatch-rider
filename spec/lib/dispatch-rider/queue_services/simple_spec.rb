# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::QueueServices::Simple do
  subject(:simple_queue) do
    DispatchRider::QueueServices::Simple.new
  end

  describe "#assign_storage" do
    it "should return an empty array" do
      expect(simple_queue.assign_storage({})).to eq([])
    end
  end

  describe "#insert" do
    it "should insert a serialized object into the queue" do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
      result = JSON.parse(simple_queue.queue.pop)
      expect(result['subject']).to eq('foo')
      expect(result['body']).to eq('bar')
    end
  end

  describe "#raw_head" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the first item from the queue" do
      result = JSON.parse(simple_queue.raw_head)
      expect(result['subject']).to eq('foo')
      expect(result['body']).to eq('bar')
    end
  end

  describe "#construct_message_from" do
    it "should return the item casted as a message" do
      result = simple_queue.construct_message_from({'subject' => 'foo', 'body' => 'bar'}.to_json)
      expect(result.subject).to eq('foo')
      expect(result.body).to eq('bar')
    end
  end

  describe "#delete" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should remove the item from the queue" do
      simple_queue.delete({'subject' => 'foo', 'body' => 'bar'}.to_json)
      expect(simple_queue).to be_empty
    end
  end

  describe "#size" do
    before :each do
      simple_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the size of the queue" do
      expect(simple_queue.size).to eq(1)
    end
  end
end
