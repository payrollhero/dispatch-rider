require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem do

  describe "#notifier_builder" do
    it "returns the notifier builder" do
      expect(subject.notifier_builder).to eq(DispatchRider::NotificationServices::FileSystem::Notifier)
    end
  end

  describe "#channel_registrar_builder" do
    it "returns the channel registrar builder" do
      expect(subject.channel_registrar_builder).to eq(DispatchRider::Registrars::FileSystemChannel)
    end
  end

  describe "#channel" do
    it "returns the channel" do
      subject.channel_registrar.register(:foo, :path => "tmp/test/channel")
      expect(subject.channel(:foo)).to be_a(DispatchRider::NotificationServices::FileSystem::Channel)
    end
  end
end
