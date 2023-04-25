# frozen_string_literal: true

require "spec_helper"

describe DispatchRider::DefaultErrorHandler do
  describe ".call" do
    let(:exception) { Exception.new("Something went terribly wrong") }

    example do
      expect {
        described_class.call("Error", exception)
      }.to raise_exception exception
    end
  end
end
