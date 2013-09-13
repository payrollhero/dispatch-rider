require 'spec_helper'

describe DispatchRider::Configuration do

  subject{ described_class.new }

  describe "defaults" do
    example do
      subject.handler_path.should =~ /\/app\/handlers/
      subject.error_handler.should == DispatchRider::DefaultErrorHandler
      subject.queue_kind.should == :file_system
      subject.queue_info.should == { path: "tmp/dispatch-rider-queue" }
      subject.subscriber.should == DispatchRider::Subscriber
    end
  end

  describe "#handlers" do
    before :each do
      subject.handler_path = "./spec/fixtures/handlers"
    end

    it "loads the files and converts their names to symbols" do
      subject.handlers.should include(:test_handler, :another_test_handler)
    end
  end
end
