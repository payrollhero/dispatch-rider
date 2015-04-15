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
    DispatchRider::NotificationServices::Base.any_instance.stub(:notifier_builder).and_return(OpenStruct)
    DispatchRider::NotificationServices::Base.any_instance.stub(:channel_registrar_builder).and_return(DispatchRider::Registrars::SnsChannel)
    DispatchRider::NotificationServices::Base.any_instance.stub(:channel) do |name|
      subject.notifier.topics[subject.fetch(name)] if name == :foo
    end
  end

  subject do
    DispatchRider::NotificationServices::Base.new({:topics => {}})
  end

  describe "#initialize" do
    it "assigns the notifier" do
      subject.notifier.should respond_to(:topics)
    end

    it "assigns the channel registrar" do
      subject.channel_registrar.store.should be_empty
    end
  end

  describe "#publish" do
    before :each do
      subject.register(:foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      subject.notifier.topics['arn:aws:sns:us-east-1:123:PlanOfAttack'] = channel
    end

    let(:message) { DispatchRider::Message.new(subject: :test_handler, body: { "bar" => "baz" }) }

    it "publishes the message to the channels" do
      catch(:published) { subject.publish to: :foo, message: message }.should eq("baz")
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

  describe "#channels" do
    before :each do
      subject.register(:foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      subject.notifier.topics['arn:aws:sns:us-east-1:123:PlanOfAttack'] = channel
    end

    it "returns an array of channels" do
      subject.channels(:foo).should eq([channel])
    end
  end
end
