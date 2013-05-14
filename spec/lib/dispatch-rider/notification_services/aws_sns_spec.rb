require 'spec_helper'

describe DispatchRider::NotificationServices::AwsSns do
  let(:amazon_resource_name){ "arn:aws:sns:us-west-2:123456789012:GeneralTopic" }

  describe "#notifier_builder" do
    it "returns the notifier builder" do
      subject.notifier_builder.should eq(AWS::SNS)
    end
  end

  describe "#channel_registrar_builder" do
    it "returns the channel registrar builder" do
      subject.channel_registrar_builder.should eq(DispatchRider::Registrars::SnsChannel)
    end
  end

  describe "#channel" do
  end
end
