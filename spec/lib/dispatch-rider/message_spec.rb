require 'spec_helper'

describe DispatchRider::Message do
  subject(:message) {DispatchRider::Message.new(:subject => 'test', :body => 'test_handler')}

  describe "#initialize" do
    context "when all the required attributes are passed" do
      context "when the attributes hash has keys as strings" do
        subject(:message) {DispatchRider::Message.new('subject' => 'test', 'body' => 'test_handler')}

        it "should initiate a new message" do
          message.subject.should eq('test')
          message.body.should eq('test_handler')
        end
      end

      context "when the attributes hash has keys as symbols" do
        it "should initiate a new message" do
          message.subject.should eq('test')
          message.body.should eq('test_handler')
        end
      end
    end

    context "when all the required attributes are not passed" do
      it "should raise an exception" do
        expect { DispatchRider::Message.new({}) }.to raise_exception(DispatchRider::RecordInvalid)
      end
    end
  end

  describe "#attributes" do
    it "should return the attributes hash of the message" do
      message.attributes.should eq({:subject => 'test', :body => 'test_handler'})
    end
  end

  describe "#to_json" do
    it "should return the attributes hash in json format" do
      result = JSON.parse(message.to_json)
      result['subject'].should eq('test')
      result['body'].should eq('test_handler')
    end
  end

  describe "#==" do
    context "when 2 messages have the same attribute values" do
      it "should return true" do
        message.should eq(DispatchRider::Message.new(:subject => 'test', :body => 'test_handler'))
      end
    end

    context "when 2 messages do not have same attribute values" do
      it "should return false" do
        message.should_not eq(DispatchRider::Message.new(:subject => 'random_test', :body => 'test_handler'))
      end
    end
  end
end
