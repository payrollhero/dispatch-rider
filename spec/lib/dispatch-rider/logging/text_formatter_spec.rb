require 'spec_helper'

describe DispatchRider::Logging::TextFormatter do
  let(:fs_message) { DispatchRider::Message.new(subject: 'test', body: { 'key' => 'value', 'guid' => 123 }) }
  let(:item) { double :item }
  let(:queue) { double :queue }
  let(:message) { DispatchRider::QueueServices::FileSystem::FsReceivedMessage.new(fs_message, item, queue) }

  let(:string_to_log) { "string to log" }
  let(:exception) { StandardError.new }
  let(:reason) { "Stop reason" }

  before do
    allow(subject).to receive(:message_info_fragment).and_return(string_to_log)
    allow(subject).to receive(:exception_info_fragment).and_return(string_to_log)
  end

  context "format_error_handler_fail" do
    let(:formatted_message) { "Failed error handling of: string to log" }
    example do
      expect(subject.format_error_handler_fail(message, exception)).to eq(formatted_message)
    end
  end

  context "format_got_stop" do
    let(:formatted_message) { "Got stop (Stop reason) while executing: string to log" }
    example do
      expect(subject.format_got_stop(message, reason)).to eq(formatted_message)
    end
  end

  context "format_handling" do
    context "start" do
      let(:formatted_message) { "Starting execution of: string to log" }
      example do
        expect(subject.format_handling(:start, message)).to eq(formatted_message)
      end
    end

    context "success" do
      let(:formatted_message) { "Succeeded execution of: string to log" }
      example do
        expect(subject.format_handling(:success, message)).to eq(formatted_message)
      end
    end

    context "complete" do
      let(:formatted_message) { "Completed execution of: string to log in 2.12 seconds" }
      example do
        expect(subject.format_handling(:complete, message, duration: 2.12)).to eq(formatted_message)
      end
    end

    context "fail" do
      let(:formatted_message) { "Failed execution of: string to log" }
      example do
        expect(subject.format_handling(:fail, message, exception: exception)).to eq(formatted_message)
      end
    end
  end
end
