# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Registrars::PublishingDestination do
  describe "#value" do
    it "returns an object which has information about a notification service and a channel" do
      result = subject.value('foo', service: :aws_sns, channel: :bar)
      expect(result.service).to eq(:aws_sns)
      expect(result.channel).to eq(:bar)
    end
  end
end
