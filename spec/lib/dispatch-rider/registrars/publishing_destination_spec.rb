require 'spec_helper'

describe DispatchRider::Registrars::PublishingDestination do
  describe "#value" do
    it "returns an object which has information about a notification service and a channel" do
      result = subject.value('foo', :service => :aws_sns, :channel => :bar)
      result.service.should eq(:aws_sns)
      result.channel.should eq(:bar)
    end
  end
end
