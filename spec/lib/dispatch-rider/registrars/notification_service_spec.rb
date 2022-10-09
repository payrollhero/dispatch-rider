# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Registrars::NotificationService do
  subject do
    described_class.new
  end

  describe "#value" do
    it "returns the value for the key/value pair while registering a notification service" do
      expect(subject.value(:aws_sns)).to be_a(DispatchRider::NotificationServices::AwsSns)
    end
  end
end
