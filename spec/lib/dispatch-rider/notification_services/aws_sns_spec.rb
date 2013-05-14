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
    before { subject.stub(:channel_registrar).and_return(foo: amazon_resource_name) }

    let(:topics){ mock :sns_topics }
    let(:topic){ mock :sns_topic }

    it "returns the channel" do
      subject.notifier.should_receive(:topics).and_return(topics)
      topics.should_receive(:[]).with(amazon_resource_name).and_return(topic)

      subject.channel(:foo).should == topic
    end
  end
end
