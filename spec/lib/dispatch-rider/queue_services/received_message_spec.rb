# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::QueueServices::ReceivedMessage do

  subject { described_class.new("test_message", double(:item)) }

  describe "#extend_timeout" do
    example do
      expect {
        subject.extend_timeout(10)
      }.to raise_error NotImplementedError
    end
  end

  describe "#return_to_queue" do
    example do
      expect {
        subject.return_to_queue
      }.to raise_error NotImplementedError
    end
  end

end
