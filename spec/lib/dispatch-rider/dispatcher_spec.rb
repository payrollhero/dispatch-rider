require 'spec_helper'

describe DispatchRider::Dispatcher, :nodb => true do
  module HandleSomething
    class << self
      def process(params)
        throw :something if params[:do_throw_something]
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
