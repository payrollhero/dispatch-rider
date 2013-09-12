require 'spec_helper'

describe DispatchRider::Callbacks::Access do
  describe "#invoke" do
    let(:callback1){ double(:callback1) }
    let(:callback2){ double(:callback2) }
    let(:callback3){ double(:callback3) }
    let(:callback4){ double(:callback4) }

    let(:callbacks){ double(:callbacks) }

    before :each do
      callbacks.stub(:for).with(:before, :initialize).and_return([callback1])
      callbacks.stub(:for).with(:after, :initialize).and_return([callback4])
      callbacks.stub(:for).with(:before, :destroy).and_return([])
      callbacks.stub(:for).with(:after, :destroy).and_return([callback2, callback3])
    end

    subject{ described_class.new(callbacks) }

    example do
      callback1.should_receive(:call).once
      callback2.should_not_receive(:call)
      callback3.should_not_receive(:call)
      callback4.should_receive(:call).once

      subject.invoke(:initialize){ true }
    end

    example do
      callback1.should_not_receive(:call)
      callback2.should_receive(:call).once
      callback3.should_receive(:call).once
      callback4.should_not_receive(:call)

      subject.invoke(:destroy){ true }
    end
  end

end
