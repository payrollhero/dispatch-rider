require 'spec_helper'

describe DispatchRider::Registrars::NotificationService do
  subject do
    described_class.new
  end

  describe "#value" do
    it "returns the value for the key/value pair while registering a notification service" do
      subject.value(:aws_sns).should be_a(DispatchRider::NotificationServices::AwsSns)
    end
  end
end
