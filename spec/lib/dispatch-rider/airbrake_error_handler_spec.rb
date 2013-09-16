require "spec_helper"

describe DispatchRider::AirbrakeErrorHandler do

  describe ".call" do
    let(:message){ DispatchRider::Message.new(subject: "TestMessage", body: "foo" )}
    let(:exception){ Exception.new("Something went terribly wrong") }

    example do
      Airbrake.should_receive(:notify).with(exception, controller: "DispatchRider", action: "TestMessage", parameters: { subject: "TestMessage", body: "foo" }, cgi_data: anything)

      described_class.call(message, exception)
    end
  end

end
