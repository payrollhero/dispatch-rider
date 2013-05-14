require 'spec_helper'

describe DispatchRider::Railtie do
  it "should set the dispatch rider as a configuration object" do
    Rails.application.config.dispatch_rider.should be_kind_of(DispatchRider::Reactor)
  end
end
