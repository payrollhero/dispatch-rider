require 'spec_helper'

describe DispatchRider::Registrars::QueueService do
  subject do
    described_class.new
  end

  describe "#value" do
    it "returns the value for the key/value pair while registering a queue service" do
      subject.value(:simple).should be_a(DispatchRider::QueueServices::Simple)
    end
  end
end
