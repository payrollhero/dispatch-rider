require "spec_helper"

describe DispatchRider::Runner do
  before :each do
    @demultiplexer = OpenStruct.new(:start => true, :stop => true)
    DispatchRider::Demultiplexer.stub!(:new).and_return(@demultiplexer)
  end

  subject do
    DispatchRider::Runner.new(DispatchRider::QueueServices::ArrayQueue.new)
  end

  it "should start the demultiplexer" do
    @demultiplexer.should_receive(:start)
    subject.run
  end
end
