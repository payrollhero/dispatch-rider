require 'spec_helper'

describe DispatchRider::Publisher do

  subject do
    described_class.new
  end

  describe "#initialize" do
    it "assigns the notification service registrar" do
      subject.notification_service_registrar.store.should be_empty
    end

    it "assigns a publishing destination registrar" do
      subject.publishing_destination_registrar.store.should be_empty
    end

    it "assigns a service channel mapper" do
      subject.service_channel_mapper.destination_registrar.store.should be_empty
    end

    context "when not passing a configuration" do
      it "loads the global configuration" do
        DispatchRider::Publisher::ConfigurationReader.should_receive(:load_config).with(described_class.configuration, subject)
      end
    end

    context "when passing a configuration" do
      let(:configuration){ DispatchRider::Publisher::Configuration.new }

      subject{ described_class.new(configuration) }

      it "loads the configuration" do
        DispatchRider::Publisher::ConfigurationReader.should_receive(:load_config).with(configuration, subject)
      end
    end
  end

  describe "#register_notification_service" do
    it "registers a notification service" do
      subject.register_notification_service(:aws_sns)
      result = subject.notification_service_registrar.fetch(:aws_sns)
      result.notifier.should respond_to(:topics)
      result.channel_registrar.store.should be_empty
    end

    it "returns the publisher" do
      subject.register_notification_service(:aws_sns).should eq(subject)
    end
  end

  describe "#register_channel" do
    before :each do
      subject.register_notification_service(:aws_sns)
    end

    let(:notification_service) { subject.notification_service_registrar.fetch(:aws_sns) }

    it "registers a channel for the notification service" do
      subject.register_channel(:aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      notification_service.channel_registrar.fetch(:foo).should eq('arn:aws:sns:us-east-1:123:PlanOfAttack')
    end

    it "returns the publisher" do
      subject.register_channel(:aws_sns, :foo).should eq(subject)
    end
  end

  describe "#register_destination" do
    before :each do
      subject.register_notification_service(:aws_sns)
    end

    it "registers the destination to be published to" do
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      result = subject.publishing_destination_registrar.fetch(:sns_foo)
      result.service.should eq(:aws_sns)
      result.channel.should eq(:foo)
    end

    it "returns the publisher" do
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack").should eq(subject)
    end
  end

  describe "#publish" do
    let :topic do
      obj = double("AWS::SNS::Topic")
      class << obj
        define_method(:publish) do |msg|
          throw :published, JSON.parse(msg)["body"]["bar"]
        end
      end
      obj
    end

    let :topic_collection do
      obj = double("AWS::SNS::TopicCollection")
      obj.stub(:[]).and_return do |key|
        topic if key == 'arn:aws:sns:us-east-1:123:PlanOfAttack'
      end
      obj
    end

    let :notifier do
      subject.notification_service_registrar.fetch(:aws_sns).notifier
    end

    before :each do
      subject.register_notification_service(:aws_sns)
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
    end

    it "publishes the message to the notification service" do
      catch :published do
        notifier.should_receive(:topics).and_return(topic_collection)
        subject.publish(:destinations => [:sns_foo], :message => {:subject => "bar_handler", :body => {"bar" => "baz"}})
      end.should eq("baz")
    end
  end
end
