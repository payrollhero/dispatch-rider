require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem::Notifier do

  subject { described_class.new({}) }

  describe "#channel" do
    example do
      subject.channel("/some/path").should be_a(DispatchRider::NotificationServices::FileSystem::Channel)
    end
  end

end

