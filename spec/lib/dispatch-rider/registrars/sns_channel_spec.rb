require 'spec_helper'

describe DispatchRider::Registrars::SnsChannel do
  describe "#value" do
    it "returns the value for the key/value pair while registering an amazon sns channel" do
      subject.value(:foo).should eq('foo')
    end
  end
end
