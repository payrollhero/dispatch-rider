require 'spec_helper'

describe DispatchRider::Dispatcher, :nodb => true do
  module HandleSomething
    class << self
      def process(params)
        throw :something if params[:do_throw_something]
      end
    end
  end

  module FailHandling
    class << self
      def process(params)
        raise Exception.new("failed")
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

    describe "when error handling" do
      let(:message){ DispatchRider::Message.new(:subject => "fail_handling", :body => { :do_throw_something => true }) }

      before do
        subject.register('fail_handling')
      end

      context "when error handling is not defined" do
        it "raises the original error" do
          expect { subject.dispatch(message) }.to raise_exception("failed")
        end
      end

      context "when error handling is defined" do
        def error_handler(message, exception)
          return :flag_for_message_deletion
        end

        before do
          subject.on_error &method(:error_handler)
        end

        it "raises the original error" do
          expect {
            subject.dispatch(message).should == :flag_for_message_deletion
          }.to_not raise_exception
        end
      end
    end
  end
end
