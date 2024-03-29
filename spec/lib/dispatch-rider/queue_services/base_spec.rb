# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::QueueServices::Base do
  subject(:base_queue) do
    allow_any_instance_of(described_class).to receive(:assign_storage).and_return([])
    described_class.new
  end

  describe "#initialize" do
    it "should initiate a queue" do
      expect(base_queue.queue).to eq([])
    end
  end

  describe "#push" do
    subject(:simple_queue) { DispatchRider::QueueServices::Simple.new }

    it "should push the serialized object to the queue" do
      simple_queue.push(DispatchRider::Message.new(subject: "foo", body: "bar"))
      result = JSON.parse(simple_queue.queue.first)
      expect(result['subject']).to eq('foo')
      expect(result['body']).to eq('bar')
    end
  end

  describe "#insert" do
    it "should raise an exception" do
      expect {
        base_queue.insert(DispatchRider::Message.new(subject: "foo", body: "bar"))
      }.to raise_exception(NotImplementedError)
    end
  end

  describe "#pop" do
    subject(:simple_queue) { DispatchRider::QueueServices::Simple.new }

    before do
      simple_queue.queue.push(DispatchRider::Message.new(subject: "foo", body: "bar").to_json)
    end

    context "when the block passed to process the popped message returns true" do
      it "should return the first message in the queue" do
        response = simple_queue.pop { |_msg| true }
        expect(response).to eq(DispatchRider::Message.new(subject: 'foo', body: 'bar'))
      end
    end

    context "when the block passed to process the popped message returns false" do
      it "should return the first message in the queue" do
        result = simple_queue.pop { |_msg| false }
        expect(result).to eq(DispatchRider::Message.new(subject: 'foo', body: 'bar'))
      end

      it "should not remove the first message from the queue" do
        simple_queue.pop do |msg|
          msg.body = { bar: "baz" }
          false
        end
        expect(simple_queue).not_to be_empty
      end
    end

    context "when the queue is empty" do
      before do
        simple_queue.queue = []
      end

      it "should return nil" do
        result = simple_queue.pop do |msg|
          msg.body = { bar: "baz" }
          true
        end
        expect(result).to be_nil
      end
    end
  end

  describe "#head" do
    before do
      allow(base_queue).to receive(:raw_head) { new_item }
    end

    context "when there is no new item" do
      let(:new_item) { nil }

      it "should raise an exception" do
        expect(base_queue.head).to be_nil
      end
    end

    context "when a new item exists" do
      before do
        allow(base_queue).to receive(:construct_message_from, &:message)
      end

      let(:new_item) { OpenStruct.new(message: new_message) }
      let(:new_message) { :the_message }

      it "should return the expected message" do
        received_head = base_queue.head
        expect(received_head.item).to eq new_item
        expect(received_head.to_sym).to eq new_message
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
      expect {
        base_queue.construct_message_from({ subject: 'foo', body: { bar: 'baz' } }.to_json)
      }.to raise_exception(NotImplementedError)
    end
  end

  describe "#delete" do
    it "should raise an exception" do
      expect {
        base_queue.delete({ subject: 'foo', body: { bar: 'baz' } }.to_json)
      }.to raise_exception(NotImplementedError)
    end
  end

  describe "#empty?" do
    before do
      allow(base_queue).to receive(:size) { base_queue.queue.size }
    end

    context "when the queue is empty" do
      before do
        base_queue.queue = []
      end

      it "should return true" do
        expect(base_queue).to be_empty
      end
    end

    context "when the queue is not empty" do
      before do
        base_queue.queue << { subject: 'foo', body: 'bar' }.to_json
      end

      it "should return false" do
        expect(base_queue).not_to be_empty
      end
    end
  end

  describe "#size" do
    it "should raise an exception" do
      expect { base_queue.size }.to raise_exception(NotImplementedError)
    end
  end
end
