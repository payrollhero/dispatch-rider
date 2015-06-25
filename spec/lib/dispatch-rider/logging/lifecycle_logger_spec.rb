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

  context 'when log formatter is json' do
    before { DispatchRider.config.log_formatter = DispatchRider::Logging::JsonFormatter.new }

    context 'when additional_info_interjector is customized' do
      let(:additional_info_interjector) do
        -> (message) do
          message[:employee_id] = 47
          message[:account_id] = 42
        end
      end

      before do
        DispatchRider.config.additional_info_interjector = additional_info_interjector
      end

      describe 'log_error_handler_fail' do
        let(:expected_info) do
          {
            phase: 'error_handler_fail',
            guid: '123',
            subject: 'test',
            body: { some: 'key' },
            exception: { class: 'StandardError', message: 'something failed' },
            employee_id: 47,
            account_id: 42,
          }.deep_stringify_keys.to_json
        end

        it "calls logger with error" do
          expect(logger).to receive(:error).with(expected_info)
          subject.log_error_handler_fail fs_message, exception
        end
      end

      describe "log_got_stop" do
        let(:expected_info) do
          {
            phase: 'stop',
            guid: '123',
            subject: 'test',
            body: { some: 'key' },
            reason: reason,
            employee_id: 47,
            account_id: 42,
          }.deep_stringify_keys.to_json
        end

        it "calls logger with info" do
          expect(logger).to receive(:info).with(expected_info)
          subject.log_got_stop reason, fs_message
        end
      end

      describe "wrap_handling" do
        let(:expected_start_info) do
          {
            phase: 'start',
            guid: '123',
            subject: 'test',
            body: { some: 'key' },
            employee_id: 47,
            account_id: 42,
          }.deep_stringify_keys.to_json
        end

        let(:expected_succeed_info) do
          {
            phase: 'success',
            guid: '123',
            subject: 'test',
            body: { some: 'key' },
            employee_id: 47,
            account_id: 42,
          }.deep_stringify_keys.to_json
        end

        let(:expected_complete_info) do
          /{\"phase\"\:\"complete\",\"guid\"\:\"123\",\"subject\"\:\"test\",\"body\"\:{\"some\"\:\"key\"},\"duration\"\:\d+(?:.\d+)?,\"employee_id\"\:47,\"account_id\"\:42}/
        end

        context 'succeeding the handler' do
          example do
            expect(logger).to receive(:info).with(expected_start_info)
            expect(logger).to receive(:info).with(expected_succeed_info)
            expect(logger).to receive(:info).with(expected_complete_info)
            expect {
              subject.wrap_handling(fs_message) { true }
            }.not_to raise_exception
          end
        end
      end
    end

    context 'when log formatter is text based' do
      before do
        DispatchRider.config.log_formatter = DispatchRider::Logging::TextFormatter.new
      end

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
end
