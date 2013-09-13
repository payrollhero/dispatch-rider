require 'spec_helper'

describe DispatchRider do

  describe ".configuration" do
    example do
      described_class.configuration.should be_a(DispatchRider::Configuration)
    end
  end

  describe ".config" do
    example do
      described_class.config.should be_a(DispatchRider::Configuration)
    end
  end

  describe ".configure" do
    example do
      described_class.configure do |config|
        config.queue_kind = :test_queue
      end

      described_class.config.queue_kind.should == :test_queue
    end
  end

end
