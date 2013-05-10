require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem do

  describe "#notifier_builder" do
    it "returns the notifier builder" do
      subject.notifier_builder.should eq(DispatchRider::NotificationServices::FileSystem::Notifier)
    end
  end

  describe "#channel_registrar_builder" do
    it "returns the channel registrar builder" do
      subject.channel_registrar_builder.should eq(DispatchRider::Registrars::FileSystemChannel)
    end
  end

  describe "#channel" do
    #before { subject.stub(:channel_registrar).and_return(foo: amazon_resource_name) }

    #let(:topics){ mock :sns_topics }
    #let(:topic){ mock :sns_topic }

    it "returns the channel" do
      subject.channel_registrar.register(:foo, :path => "test/channel")
      subject.channel(:foo).should be_a(DispatchRider::NotificationServices::FileSystem::Channel)
    end
  end
end
