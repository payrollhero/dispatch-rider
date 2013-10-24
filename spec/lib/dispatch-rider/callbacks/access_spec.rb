require 'spec_helper'

describe DispatchRider::Callbacks::Access do
  describe "#invoke" do

    let(:callback_a1) { proc { |x| x.call } }
    let(:callback_a2) { proc { |x| x.call } }
    let(:callback_a3) { proc { |x| x.call } }
    let(:callbacks_a) { [callback_a1, callback_a2, callback_a3] }

    let(:callback_b1) { proc { |x| x.call } }
    let(:callbacks_b) { [callback_b1] }

    let(:storage) { DispatchRider::Callbacks::Storage.new }
    let(:action) { proc { } }

    subject { described_class.new(storage) }

    before do
      callbacks_a.each do |cb|
        storage.around :event1, cb
      end
      callbacks_b.each do |cb|
        storage.around :event2, cb
      end
    end

    example "a bunch of handlers" do
      callback_a1.should_receive(:call).once.and_call_original
      callback_a2.should_receive(:call).once.and_call_original
      callback_a3.should_receive(:call).once.and_call_original
      callback_b1.should_not_receive(:call)

      action.should_receive(:call).once.and_call_original

      subject.invoke(:event1, &action)
    end

    example "single handler" do
      callback_a1.should_not_receive(:call)
      callback_a2.should_not_receive(:call)
      callback_a3.should_not_receive(:call)
      callback_b1.should_receive(:call).once.and_call_original

      action.should_receive(:call).once.and_call_original

      subject.invoke(:event2, &action)
    end

    example "no handlers" do
      callback_a1.should_not_receive(:call)
      callback_a2.should_not_receive(:call)
      callback_a3.should_not_receive(:call)
      callback_b1.should_not_receive(:call)

      action.should_receive(:call).once.and_call_original

      subject.invoke(:event3, &action)
    end
  end

end
