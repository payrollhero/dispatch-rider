require 'spec_helper'

describe DispatchRider::Dispatcher, :nodb => true do
  module HandleSomething
    class << self
      def process(params)
        throw :something if params[:do_throw_something]
      end
    end
  end

  describe "#initialize" do
    it "should assign an empty handlers container" do
      subject.handlers.should be_empty
    end
  end

  describe "#register" do
    context "when the handler exists" do
      it "should insert the handler in the handlers container" do
        subject.register('handle_something')
        subject.handlers[:handle_something].should eq(HandleSomething)
      end
    end

    context "when the handler does not exist" do
      it "should raise an exception" do
        expect { subject.register('foo') }.to raise_exception(DispatchRider::NotFound)
      end
    end
  end

  describe "#unregister" do
    before :each do
      subject.register('handle_something')
    end

    it "should remove the handler from the handlers container" do
      subject.unregister(:handle_something)
      subject.handlers.should be_empty
    end
  end

  describe "#fetch" do
    context "when a handler is registered" do
      before :each do
        subject.register('handle_something')
      end

      it "should return the handler" do
        subject.fetch(:handle_something).should eq(HandleSomething)
      end
    end

    context "when a handler is not registered" do
      it "should raise an exception" do
        expect { subject.fetch(:foo) }.to raise_exception(DispatchRider::NotRegistered)
      end
    end
  end

  describe "#dispatch" do
    let(:message){ DispatchRider::Message.new(:subject => "handle_something", :body => { :do_throw_something => true }) }

    context "when the handler provided in the message is present" do
      before :each do
        subject.register('handle_something')
      end

      it "should process the message" do
        expect { subject.dispatch(message) }.to throw_symbol(:something)
      end
    end
  end
end
