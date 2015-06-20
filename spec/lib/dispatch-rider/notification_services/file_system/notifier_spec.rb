require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem::Notifier do
  subject { described_class.new({}) }

  describe "#channel" do
    it "returns a channel object" do
      expect(subject.channel("tmp/some/path")).to be_a(DispatchRider::NotificationServices::FileSystem::Channel)
    end
  end
end

