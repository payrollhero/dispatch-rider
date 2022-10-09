# frozen_string_literal: true

require "spec_helper"

describe DispatchRider::AirbrakeErrorHandler do

  describe ".call" do
    let(:message) { DispatchRider::Message.new(subject: "TestMessage", body: "foo") }
    let(:exception) { Exception.new("Something went terribly wrong") }

    example do
      args = [
        exception,
        controller: "DispatchRider",
        action: "TestMessage",
        parameters: { subject: "TestMessage", body: "foo" },
        cgi_data: anything
      ]
      expect(Airbrake).to receive(:notify).with(*args)

      described_class.call(message, exception)
    end
  end

end
