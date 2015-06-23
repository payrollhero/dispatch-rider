require 'spec_helper'

describe DispatchRider::Runner do

  describe ".run" do
    let(:subscriber) { double(:subscriber) }

    before :each do
      DispatchRider.configure do |config|
        config.subscriber = subscriber
      end
    end

    after do
      DispatchRider.clear_configuration!
    end

    example do
      expect(subscriber).to receive(:new).once.and_return(subscriber)
      expect(subscriber).to receive(:register_queue).once
      expect(subscriber).to receive(:setup_demultiplexer).once
      expect(subscriber).to receive(:process).once
      allow(subscriber).to receive(:register_handler)

      described_class.run
    end
  end

end
