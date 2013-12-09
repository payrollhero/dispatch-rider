require 'spec_helper'

describe DispatchRider::Runner do

  describe ".run" do
    let(:subscriber){ double(:subscriber, :logger= => nil) }

    before :each do
      DispatchRider.configure do |config|
        config.subscriber = subscriber
      end
    end

    example do
      subscriber.should_receive(:new).once.and_return(subscriber)
      subscriber.should_receive(:register_queue).once
      subscriber.should_receive(:setup_demultiplexer).once
      subscriber.should_receive(:process).once
      subscriber.stub(:register_handler)

      described_class.run
    end
  end

end
