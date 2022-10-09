# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Registrars::Handler do
  module CustomTestHandler
  end

  subject do
    described_class.new
  end

  describe "#value" do
    it "returns the value for the key/value pair while registering a handler" do
      expect(subject.value(:custom_test_handler)).to eq(CustomTestHandler)
    end
  end
end
