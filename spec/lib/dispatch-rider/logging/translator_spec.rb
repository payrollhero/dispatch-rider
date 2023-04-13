# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Logging::Translator do
  let(:queue) { double :queue }
  let(:message) { build(:message) }
  let(:item) { double :item }
  let(:fs_message) { DispatchRider::QueueServices::FileSystem::FsReceivedMessage.new(message, item, queue) }

  let(:exception) { nil }
  let(:duration) { nil }
  let(:reason) { nil }

  describe '.translate' do
    context 'when the job is starting' do
      subject(:result) do
        described_class.translate(fs_message, kind)
      end

      let(:kind) { :start }
      let(:expected_hash) do
        {
          phase: :start,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end

    context 'when the job has succeeded' do
      subject(:result) do
        described_class.translate(fs_message, kind)
      end

      let(:kind) { :success }
      let(:expected_hash) do
        {
          phase: :success,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end

    context 'when the job has failed' do
      subject(:result) do
        described_class.translate(fs_message, kind, exception: exception)
      end

      let(:kind) { :fail }
      let(:exception) do
        ArgumentError.new("Foo is not bar")
      end

      let(:expected_hash) do
        {
          phase: :fail,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
          exception: {
            class: 'ArgumentError',
            message: 'Foo is not bar',
          }
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end

    context 'when the job has completed' do
      subject(:result) do
        described_class.translate(fs_message, kind, duration: duration)
      end

      let(:kind) { :complete }
      let(:duration) { 5 }
      let(:expected_hash) do
        {
          phase: :complete,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
          duration: 5,
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end

    context 'when the error handler fails' do
      subject(:result) do
        described_class.translate(fs_message, kind, exception: exception)
      end

      let(:kind) { :error_handler_fail }
      let(:exception) do
        ArgumentError.new("Foo is not bar")
      end

      let(:expected_hash) do
        {
          phase: :error_handler_fail,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
          exception: {
            class: 'ArgumentError',
            message: 'Foo is not bar',
          }
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end

    context 'when the job has completed' do
      subject(:result) do
        described_class.translate(fs_message, kind, reason: reason)
      end

      let(:kind) { :stop }
      let(:reason) { "Got TERM" }
      let(:expected_hash) do
        {
          phase: :stop,
          subject: 'sample_handler',
          guid: DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          body: {
            'key' => 'value',
          },
          reason: 'Got TERM',
        }
      end

      example do
        expect(result).to eq(expected_hash)
      end
    end
  end
end
