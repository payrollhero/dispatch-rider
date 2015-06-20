require 'spec_helper'

describe DispatchRider::NotificationServices::Base do
  let :channel do
    channel = OpenStruct.new
    class << channel
      def publish(msg)
        throw :published, JSON.parse(msg)["body"]["bar"]
      end
    end
    channel
  end

  before :each do
    allow_any_instance_of(described_class).to receive(:notifier_builder).and_return(OpenStruct)
    channel = DispatchRider::Registrars::SnsChannel
    allow_any_instance_of(described_class).to receive(:channel_registrar_builder).and_return(channel)
    allow_any_instance_of(described_class).to receive(:channel) do |name|
      subject.notifier.topics[subject.fetch(name)] if name == :foo
    end
  end

  subject do
    DispatchRider::NotificationServices::Base.new(topics: {})
  end

  describe "#initialize" do
    it "assigns the notifier" do
      expect(subject.notifier).to respond_to(:topics)
    end

    it "assigns the channel registrar" do
      expect(subject.channel_registrar.store).to be_empty
    end
  end

  describe "#publish" do
    before :each do
      subject.register(:foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      subject.notifier.topics['arn:aws:sns:us-east-1:123:PlanOfAttack'] = channel
    end

    let(:message) { DispatchRider::Message.new(subject: :test_handler, body: { "bar" => "baz" }) }

    it "publishes the message to the channels" do
      expect(catch(:published) { subject.publish to: :foo, message: message }).to eq("baz")
    end
  end

  describe "#publish_to_channel" do
    let(:channel) { double(:channel) }

    let(:message) { DispatchRider::Message.new(subject: :test_handler, body: { "bar" => "baz" }) }
    let(:expected_message) do
      {
        "subject" => "test_handler",
        "body" => { "bar" => "baz" }
      }
    end

    # @note: This is tested this way cause you don't really wanna post a message to the actual service.
    it "publishes the message to the channels" do
      expect(channel).to receive(:publish).with(kind_of String) { |serialized_message|
                           parsed_message = JSON.parse(serialized_message)
                           expect(parsed_message).to eq(expected_message)
                         }

      subject.publish_to_channel(channel, message: message)
    end
  end

  describe "#channels" do
    before :each do
      subject.register(:foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      subject.notifier.topics['arn:aws:sns:us-east-1:123:PlanOfAttack'] = channel
    end

    it "returns an array of channels" do
      expect(subject.channels(:foo)).to eq([channel])
    end
  end
end
