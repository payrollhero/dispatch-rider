require 'spec_helper'

describe DispatchRider::Logging::TextFormatter do
  describe "#format" do
    subject(:format_result) { described_class.new.format(data) }

    let(:data) do
      {
        phase: phase,
        guid: '123',
        body: { foo: :bar },
        subject: 'sample_handler',
      }
    end

    context 'when phase is :complete' do
      let(:phase) { :complete }

      before { data[:duration] = 10 }

      example do
        expect(format_result).to eq("Completed execution of: (123): sample_handler : {:foo=>:bar} in 10.00 seconds")
      end
    end

    context 'when phase is :fail' do
      let(:phase) { :fail }

      before { data[:exception] = { class: StandardError, message: 'Foo is not bar' } }

      example do
        expect(format_result).to eq("Failed execution of: (123): sample_handler with StandardError: Foo is not bar")
      end
    end

    context 'when phase is :start' do
      let(:phase) { :start }

      example do
        expect(format_result).to eq("Starting execution of: (123): sample_handler : {:foo=>:bar}")
      end
    end

    context 'when phase is :success' do
      let(:phase) { :success }

      example do
        expect(format_result).to eq("Succeeded execution of: (123): sample_handler : {:foo=>:bar}")
      end
    end

    context 'when phase is :stop' do
      let(:phase) { :stop }

      before { data[:reason] = 'Ninja Attack' }

      example do
        expect(format_result).to eq("Got stop (Ninja Attack) while executing: (123): sample_handler : {:foo=>:bar}")
      end
    end

    context 'when phase is :error_handler_fail' do
      let(:phase) { :error_handler_fail }

      before { data[:exception] = { class: StandardError, message: 'Foo is not bar' } }

      example do
        expect(format_result).to eq(
          "Failed error handling of: (123): sample_handler with StandardError: Foo is not bar"
        )
      end
    end
  end
end
