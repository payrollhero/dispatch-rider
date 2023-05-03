# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::QueueServices::FileSystem do
  subject(:file_system_queue) do
    described_class.new(path: queue_path)
  end

  let(:queue_path) { "tmp/queue" }

  before { file_system_queue.send(:queue).send(:file_paths).each { |file| File.unlink(file) } }

  describe "#assign_storage" do
    it "should return an empty array" do
      expected_type = DispatchRider::QueueServices::FileSystem::Queue
      expect(file_system_queue.assign_storage(path: queue_path)).to be_a expected_type
    end
  end

  describe "#insert" do
    it "should insert a serialized object into the queue" do
      file_system_queue.insert({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
      result = JSON.parse(file_system_queue.queue.pop.read)
      expect(result['subject']).to eq('foo')
      expect(result['body']).to eq('bar')
    end
  end

  describe "#raw_head" do
    before do
      file_system_queue.insert({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
    end

    it "should return the first item from the queue" do
      result = JSON.parse(file_system_queue.raw_head.read)
      expect(result['subject']).to eq('foo')
      expect(result['body']).to eq('bar')
    end
  end

  describe "#construct_message_from" do
    let(:new_file) do
      file = Tempfile.new('item')
      file.write({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
      file.rewind
      file
    end

    it "should return the item casted as a message" do
      result = file_system_queue.construct_message_from(new_file)
      expect(result.subject).to eq('foo')
      expect(result.body).to eq('bar')
    end
  end

  describe "#put_back" do
    before do
      file_system_queue.insert({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
    end

    it "should remove and re-add the item" do
      file = file_system_queue.raw_head
      expect(file_system_queue).to be_empty
      file_system_queue.put_back(file)
      expect(file_system_queue.size).to eq(1)
    end
  end

  describe "#delete" do
    before do
      file_system_queue.insert({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
    end

    it "should remove the item from the queue" do
      file = File.new(Dir["#{queue_path}/*.ready"].first, "w")
      file_system_queue.delete(file)
      expect(file_system_queue).to be_empty
    end
  end

  describe "#size" do
    before do
      file_system_queue.insert({ 'subject' => 'foo', 'body' => 'bar' }.to_json)
    end

    it "should return the size of the queue" do
      expect(file_system_queue.size).to eq(1)
    end
  end
end
