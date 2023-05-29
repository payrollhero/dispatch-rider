# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider do
  describe ".configuration" do
    example do
      expect(described_class.configuration).to be_a(DispatchRider::Configuration)
    end
  end

  describe ".config" do
    example do
      expect(described_class.config).to be_a(DispatchRider::Configuration)
    end
  end

  describe ".configure" do
    example do
      described_class.configure do |config|
        config.queue_kind = :test_queue
      end

      expect(described_class.config.queue_kind).to eq(:test_queue)
    end
  end
end
