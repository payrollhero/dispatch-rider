# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Registrars::SnsChannel do
  describe "#value" do
    let(:account) { "123456789012" }
    let(:region) { "us-west-2" }
    let(:topic_name) { "GeneralTopic" }
    let(:channel_options) { { account: account, region: region, topic: topic_name } }

    it "returns the value for the key/value pair while registering an amazon sns channel" do
      expect(subject.value(:foo, channel_options)).to eq("arn:aws:sns:us-west-2:123456789012:GeneralTopic")
    end
  end
end
