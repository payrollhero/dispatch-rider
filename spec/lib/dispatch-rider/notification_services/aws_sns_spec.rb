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

  describe "#publish_to_channel" do
    let(:channel) { double(:channel) }
    let(:message) { DispatchRider::Message.new(subject: :test_handler, body: { "bar" => "baz" }) }

    # @note: This is tested this way cause you don't really wanna post a message to the actual service.
    it "publishes the message to the channels" do
      expect(channel).to receive(:publish).with(kind_of String) { |serialized_message|
        expect(JSON.parse(serialized_message)).to eq(
          "subject" => "test_handler",
          "body" => { "bar" => "baz" }
        )
      }

      subject.publish_to_channel(channel, message: message)
    end
  end

  describe "#channel" do
    before { subject.stub(:channel_registrar).and_return(foo: amazon_resource_name) }

    let(:topics){ double :sns_topics }
    let(:topic){ double :sns_topic }

    it "returns the channel" do
      subject.channel(:foo).arn.should == amazon_resource_name
    end
  end
end
