require 'spec_helper'

describe DispatchRider::Dispatcher, :nodb => true do

  module HandleSomething
    class << self
      def process(params)
        # throw something so we know the dispatcher made this handler process the message
        throw :something if params[:do_throw_something]
      end
    end
  end

  before do
    dispatcher_handlers.clear
  end

  subject do
    DispatchRider::Dispatcher
  end

  let(:dispatcher_handlers) { subject.instance_variable_get("@handlers") }

  let(:handle_something_message){ DispatchRider::Message.new(:subject => "handle_something", :body => { :do_throw_something => true }) }

  describe ".register" do
    it "should register handler" do
      expect { described_class.register :handle_something }.to change(dispatcher_handlers, :count).by(1)

      dispatcher_handlers[:handle_something].should be HandleSomething
    end
  end

  describe ".unregister" do
    before { described_class.register :handle_something }

    it "should unregister handler" do
      expect { described_class.unregister :handle_something }.to change(dispatcher_handlers, :count).by(-1)

      dispatcher_handlers[:handle_something].should be_nil
    end
  end

  describe ".dispatch" do
    before { described_class.register :handle_something }

    it "should dispatch item to registered handler" do
      expect{ described_class.dispatch(handle_something_message) }.to throw_symbol( :something )
    end
  end

end
