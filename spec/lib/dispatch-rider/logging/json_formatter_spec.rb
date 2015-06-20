require 'spec_helper'

describe DispatchRider::Logging::JsonFormatter do
  let(:fs_message) { DispatchRider::Message.new(subject: 'test', body: { 'key' => 'value', 'guid' => 123 }) }
  let(:item) { double }
  let(:queue) { double }
  let(:message) { DispatchRider::QueueServices::FileSystem::FsReceivedMessage.new(fs_message, item, queue) }
  let(:exception) { StandardError.new }
  let(:reason) { "Stop reason" }

  let(:result_object) do
    {
      "subject" => "test",
      "guid" => "123",
      "body" => {
        "key" => "value"
      },
    }
  end
  let(:result_exception) do
    {
      "expection" => {
        "class" => "StandardError",
        "message" => "StandardError"
      }
    }
  end

  context "format_error_handler_fail" do
    let(:formatted_message) { result_object.merge("phase" => "failed").merge(result_exception) }
    let(:result_message) { JSON.parse subject.format_error_handler_fail(message, exception) }

    example { expect(result_message).to eq(formatted_message) }
  end

  context "format_got_stop" do
    let(:formatted_message) { result_object.merge("phase" => "stop", "reason" => reason) }
    let(:result_message) { JSON.parse subject.format_got_stop(message, reason) }

    example { expect(result_message).to eq(formatted_message) }
  end

  context "format_handling" do
    context "start" do
      let(:formatted_message) { result_object.merge("phase" => "start") }
      let(:result_message) { JSON.parse subject.format_handling(:start, message) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "success" do
      let(:formatted_message) { result_object.merge("phase" => "success") }
      let(:result_message) { JSON.parse subject.format_handling(:success, message) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "complete" do
      let(:formatted_message) { result_object.merge("phase" => "complete", "duration" => "2.00") }
      let(:result_message) { JSON.parse subject.format_handling(:complete, message, duration: 2.0) }

      example { expect(result_message).to eq(formatted_message) }
    end

    context "fail" do
      let(:formatted_message) { result_object.merge("phase" => "fail").merge(result_exception) }
      let(:result_message) { JSON.parse subject.format_handling(:fail, message, exception: exception) }

      example { expect(formatted_message).to eq(formatted_message) }
    end
  end
end
