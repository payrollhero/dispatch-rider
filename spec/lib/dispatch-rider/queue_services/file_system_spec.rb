require 'spec_helper'

describe DispatchRider::QueueServices::FileSystem do
  let(:queue_path) { "tmp/queue" }

  subject(:file_system_queue) do
    DispatchRider::QueueServices::FileSystem.new(:path => queue_path)
  end

  before { file_system_queue.send(:queue).send(:file_paths).each{|file| File.unlink(file)} }

  describe "#assign_storage" do
    it "should return an empty array" do
      file_system_queue.assign_storage({:path => queue_path}).should be_a DispatchRider::QueueServices::FileSystem::Queue
    end
  end

  describe "#insert" do
    it "should insert a serialized object into the queue" do
      file_system_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
      result = JSON.parse(file_system_queue.queue.pop.read)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#raw_head" do
    before :each do
      file_system_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the first item from the queue" do
      result = JSON.parse(file_system_queue.raw_head.read)
      result['subject'].should eq('foo')
      result['body'].should eq('bar')
    end
  end

  describe "#construct_message_from" do
    let(:new_file) do
      file = Tempfile.new('item')
      file.write({'subject' => 'foo', 'body' => 'bar'}.to_json)
      file.rewind
      file
    end

    it "should return the item casted as a message" do
      result = file_system_queue.construct_message_from(new_file)
      result.subject.should eq('foo')
      result.body.should eq('bar')
    end
  end

  describe "#delete" do
    before :each do
      file_system_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should remove the item from the queue" do
      file = File.new(Dir["#{queue_path}/*.ready"].first, "w")
      file_system_queue.delete(file)
      file_system_queue.should be_empty
    end
  end

  describe "#size" do
    before :each do
      file_system_queue.insert({'subject' => 'foo', 'body' => 'bar'}.to_json)
    end

    it "should return the size of the queue" do
      file_system_queue.size.should eq(1)
    end
  end
end
