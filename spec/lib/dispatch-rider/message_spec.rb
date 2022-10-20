# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Message do
  subject(:message) { described_class.new(subject: 'test', body: 'test_handler') }

  describe "#initialize" do
    context "when all the required attributes are passed" do
      context "when the attributes hash has keys as strings" do
        subject(:message) { described_class.new('subject' => 'test', 'body' => 'test_handler') }

        it "should initiate a new message" do
          expect(message.subject).to eq('test')
          expect(message.body).to eq('test_handler')
        end
      end

      context "when the attributes hash has keys as symbols" do
        it "should initiate a new message" do
          expect(message.subject).to eq('test')
          expect(message.body).to eq('test_handler')
        end
      end
    end

    context "when all the required attributes are not passed" do
      it "should raise an exception" do
        expect { described_class.new({}) }.to raise_exception(DispatchRider::RecordInvalid)
      end
    end
  end

  describe "#attributes" do
    it "should return the attributes hash of the message" do
      expect(message.attributes).to eq(subject: 'test', body: 'test_handler')
    end
  end

  describe "#to_json" do
    it "should return the attributes hash in json format" do
      result = JSON.parse(message.to_json)
      expect(result['subject']).to eq('test')
      expect(result['body']).to eq('test_handler')
    end
  end

  describe "#==" do
    context "when 2 messages have the same attribute values" do
      it "should return true" do
        expect(message).to eq(described_class.new(subject: 'test', body: 'test_handler'))
      end
    end

    context "when 2 messages do not have same attribute values" do
      it "should return false" do
        expect(message).not_to eq(described_class.new(subject: 'random_test', body: 'test_handler'))
      end
    end
  end
end
