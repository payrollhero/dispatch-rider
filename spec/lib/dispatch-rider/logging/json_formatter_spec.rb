# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Logging::JsonFormatter do
  let(:data) { { some: :data } }

  let(:formatted_data) { %({"some":"data"}) }

  example do
    expect(described_class.new.format(data)).to eq(formatted_data)
  end
end
