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

    it "publishes the message to the channels" do
      catch :published do
        subject.publish(:to => :foo, :message => {:subject => :test_handler, :body => {"bar" => "baz"}})
      end.should eq('baz')
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

  describe "#message_builder" do
    it "should return the message builder class" do
      subject.message_builder.should eq(DispatchRider::Message)
    end
  end
end
