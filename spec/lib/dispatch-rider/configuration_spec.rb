require 'spec_helper'

describe DispatchRider::Configuration do

  subject{ described_class.new }

  describe "defaults" do
    example do
      expect(subject.handler_path).to match_regex(/\/app\/handlers/)
      expect(subject.error_handler).to eq DispatchRider::DefaultErrorHandler
      expect(subject.queue_kind).to eq :file_system
      expect(subject.queue_info).to eq({ path: "tmp/dispatch-rider-queue" })
      expect(subject.subscriber).to eq DispatchRider::Subscriber
    end
  end

  describe "#before" do
    example do
      expect(subject).to respond_to :before
    end
  end

  describe "#after" do
    example do
      expect(subject).to respond_to :after
    end
  end

  describe "#around" do
    example do
      expect(subject).to respond_to :around
    end
  end

  describe "#handlers" do
    before :each do
      subject.handler_path = "./spec/fixtures/handlers"
    end

    it "loads the files and converts their names to symbols" do
      expect(subject.handlers).to include(:test_handler, :another_test_handler)
    end
  end

  describe "#default_retry_timeout" do
    it "sets the default timeout" do
      subject.default_retry_timeout = 60
      expect(TestHandler.instance_methods).to include(:retry_timeout)
      #Need to do this so that all the other tests don't have this as default!
      DispatchRider::Handlers::Base.send(:remove_method,:retry_timeout)
    end
  end

  describe "#logger" do

    describe "default" do
      example { expect(subject.logger).to be_kind_of(Logger) }
    end

    example { expect(subject).to respond_to(:logger) }
  end

  describe "#logger=" do
    let(:new_logger) { double(:logger) }

    example { expect(subject).to respond_to(:logger=) }

    example do
      subject.logger = new_logger
      expect(subject.logger).to eq new_logger
    end
  end

end
