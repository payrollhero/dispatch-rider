require "spec_helper"

describe DispatchRider::Runner, :nodb => true do

  it "should create a DispatchRider::Demultiplexer" do
    DispatchRider::Demultiplexer.better_receive(:new).and_return(mock(DispatchRider::Demultiplexer, :start => true, :stop => true))
    DispatchRider::Runner.run
  end

  it "should start demultiplexing" do
    DispatchRider::Demultiplexer.any_instance.better_receive(:start)
    DispatchRider::Runner.run
  end

end
