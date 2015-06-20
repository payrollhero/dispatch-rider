require 'spec_helper'

describe DispatchRider::Logging::LifecycleLogger do
  subject { DispatchRider::Logging::LifecycleLogger }

  let(:message) { DispatchRider::Message.new(subject: 'test', body: 'test_handler') }
  let(:string_to_log) { "string to log" }
  let(:exception) { StandardError.new }
  let(:reason) { "Stop reason" }

  let(:formatter) { DispatchRider.config.log_formatter }
  let(:logger) { DispatchRider.config.logger }

  before do
    allow(formatter).to receive(:format_got_stop).and_return(string_to_log)
    allow(formatter).to receive(:format_error_handler_fail).and_return(string_to_log)
    allow(formatter).to receive(:format_handling).and_return(string_to_log)
  end

  context "log_error_handler_fail" do
    after { subject.log_error_handler_fail message, exception }

    it "calls logger with error" do
      expect(logger).to receive(:error).with(string_to_log)
    end
  end

  context "log_got_stop" do
    after { subject.log_got_stop reason, message }

    it "calls logger with info" do
      expect(logger).to receive(:info).with(string_to_log)
    end
  end

  context "wrap_handling" do
    context "block runs successfully" do
      let(:block) { Proc.new { true } }
      after { subject.wrap_handling(message, &block) }

      it "logs start" do
        expect(subject).to receive(:log_start).with(message)
      end

      it "logs success" do
        expect(subject).to receive(:log_success).with(message)
      end

      it "logs complete" do
        expect(subject).to receive(:log_complete).with(message, an_instance_of(Float))
      end
    end

    context "block fails" do
      let(:block) { Proc.new { raise exception } }
      after do
        expect { subject.wrap_handling(message, &block) }.to raise_error(exception)
      end

      it "logs start" do
        expect(subject).to receive(:log_start).with(message)
      end

      it "logs fail" do
        expect(subject).to receive(:log_fail).with(message, exception)
      end

      it "logs complete" do
        expect(subject).to receive(:log_complete).with(message, an_instance_of(Float))
      end
    end
  end
end
