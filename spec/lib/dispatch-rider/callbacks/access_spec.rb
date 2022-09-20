require 'spec_helper'

describe DispatchRider::Callbacks::Access do
  describe "#invoke" do
    subject { described_class.new(storage) }

    let(:callback_a1) { proc { |x| x.call } }
    let(:callback_a2) { proc { |x| x.call } }
    let(:callback_a3) { proc { |x| x.call } }
    let(:callbacks_a) { [callback_a1, callback_a2, callback_a3] }

    let(:callback_b1) { proc { |x| x.call } }
    let(:callbacks_b) { [callback_b1] }

    let(:storage) { DispatchRider::Callbacks::Storage.new }
    let(:action) { proc {} }

    before do
      callbacks_a.each do |cb|
        storage.around :event1, cb
      end
      callbacks_b.each do |cb|
        storage.around :event2, cb
      end
    end

    example "a bunch of handlers" do
      expect(callback_a1).to receive(:call).once.and_call_original
      expect(callback_a2).to receive(:call).once.and_call_original
      expect(callback_a3).to receive(:call).once.and_call_original
      expect(callback_b1).not_to receive(:call)

      expect(action).to receive(:call).once.and_call_original

      subject.invoke(:event1, &action)
    end

    example "single handler" do
      expect(callback_a1).not_to receive(:call)
      expect(callback_a2).not_to receive(:call)
      expect(callback_a3).not_to receive(:call)
      expect(callback_b1).to receive(:call).once.and_call_original

      expect(action).to receive(:call).once.and_call_original

      subject.invoke(:event2, &action)
    end

    example "no handlers" do
      expect(callback_a1).not_to receive(:call)
      expect(callback_a2).not_to receive(:call)
      expect(callback_a3).not_to receive(:call)
      expect(callback_b1).not_to receive(:call)

      expect(action).to receive(:call).once.and_call_original

      subject.invoke(:event3, &action)
    end
  end
end
