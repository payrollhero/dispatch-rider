require 'spec_helper'

describe DispatchRider::Message do
  subject(:message) {DispatchRider::Message.new(:subject => 'test', :body => 'test_handler')}

  describe "#initialize" do
    it "should initiate a new message" do
      message.subject.should eq('test')
      message.body.should eq('test_handler')
    end
  end
end
