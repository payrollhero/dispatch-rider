require 'spec_helper'

describe DispatchRider::Logging::LifecycleLogger, aggregrate_failures: true do
  subject { DispatchRider::Logging::LifecycleLogger }

  let(:queue) { double :queue }
  let(:item) { double :item }
  let(:fs_message) { DispatchRider::QueueServices::FileSystem::FsReceivedMessage.new(message, item, queue) }
  let(:message) { DispatchRider::Message.new(subject: 'test', body: { 'guid' => '123', 'some' => 'key' }) }
  let(:exception) { StandardError.new('something failed') }
  let(:reason) { "Stop reason" }

  let(:formatter) { DispatchRider.config.log_formatter }
  let(:logger) { double :logger }

  before do
    DispatchRider.config.logger = logger
  end

  after do
    DispatchRider.clear_configuration!
  end

  context 'when log formatter is text based' do
    describe "log_error_handler_fail" do
      it "calls logger with error" do
        expect(logger).to receive(:error).with("Failed error handling of: (123): test with StandardError: something failed")
        subject.log_error_handler_fail fs_message, exception
      end
    end

    describe "log_got_stop" do
      it "calls logger with info" do
        expect(logger).to receive(:info).with(%{Got stop (Stop reason) while executing: (123): test : {"some"=>"key"}})
        subject.log_got_stop reason, fs_message
      end
    end

    describe "wrap_handling" do
      context 'succeeding the handler' do
        example do
          expect(logger).to receive(:info).with(%{Starting execution of: (123): test : {"some"=>"key"}})
          expect(logger).to receive(:info).with(%{Succeeded execution of: (123): test : {"some"=>"key"}})
          expect(logger).to receive(:info).with(/Completed execution of: \(123\): test : {"some"=>"key"} in \d+(?:.\d+)? seconds/)
          expect {
            subject.wrap_handling(fs_message) { true }
          }.not_to raise_exception
        end
      end

      context 'failing the handler' do
        example do
          expect(logger).to receive(:info).with(%{Starting execution of: (123): test : {"some"=>"key"}})
          expect(logger).to receive(:error).with(%{Failed execution of: (123): test with RuntimeError: failed!})
          expect(logger).to receive(:info).with(/Completed execution of: \(123\): test : {"some"=>"key"} in \d+(?:.\d+)? seconds/)
          expect {
            subject.wrap_handling(fs_message) { raise "failed!" }
          }.to raise_exception "failed!"
        end
      end
    end
  end
end
