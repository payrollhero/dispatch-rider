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

  describe "#before" do
    example do
      subject.should respond_to(:before)
    end
  end

  describe "#after" do
    example do
      subject.should respond_to(:after)
    end
  end

  describe "#around" do
    example do
      subject.should respond_to(:around)
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
  
  describe "#default_retry_timeout" do
    it "sets the default timeout" do
      subject.default_retry_timeout = 60
      TestHandler.instance_methods.should include(:retry_timeout)
      #Need to do this so that all the other tests don't have this as default!
      DispatchRider::Handlers::Base.send(:remove_method,:retry_timeout)
    end
  end

  describe "#logger" do

    describe "default" do
      example { subject.logger.should be_kind_of(Logger) }
    end

    example { subject.should respond_to(:logger) }
  end

  describe "#logger=" do
    let(:new_logger) { double(:logger) }

    example { subject.should respond_to(:logger=) }

    example do
      subject.logger = new_logger
      subject.logger.should == new_logger
    end
  end

end
