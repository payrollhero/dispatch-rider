require 'spec_helper'

describe DispatchRider::Registrars::Handler do
  module CustomTestHandler
  end

  subject do
    described_class.new
  end

  describe "#value" do
    it "returns the value for the key/value pair while registering a handler" do
      subject.value(:custom_test_handler).should eq(CustomTestHandler)
    end
  end
end
