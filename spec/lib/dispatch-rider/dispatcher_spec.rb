# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Dispatcher, :nodb => true do
  class HandleSomething < DispatchRider::Handlers::Base
    def process(params)
      throw :something if params[:do_throw_something]
    end
  end

  class HandlerThatReturnsFalse < DispatchRider::Handlers::Base
    def process(_params)
      false
    end
  end

  describe "#dispatch" do
    let(:message_subject) { "handle_something" }
    let(:message_body) { { do_throw_something: true } }
    let(:fs_message) do
      DispatchRider::Message.new(subject: message_subject, body: message_body.merge('guid' => 123))
    end
    let(:item) { double :item }
    let(:queue) { double :queue }
    let(:message) { DispatchRider::QueueServices::FileSystem::FsReceivedMessage.new(fs_message, item, queue) }

    describe "callbacks" do
      let(:dummy) { double(:dummy) }
      let(:storage) { DispatchRider::Callbacks::Storage.new }

      before do
        allow(DispatchRider.config).to receive(:callbacks) { storage }
        storage.around(:dispatch_message) do |block, message|
          dummy.before
          dummy.log(message)
          block.call
        ensure
          dummy.after
        end
        subject.register('handle_something')
      end

      example do
        expect(dummy).to receive(:before).once
        expect(dummy).to receive(:after).once
        expect(dummy).to receive(:log).with(message).once
        catch(:something) do
          subject.dispatch(message)
        end
      end
    end

    context "when the handler provided in the message is present" do
      before do
        subject.register('handle_something')
      end

      it "should process the message" do
        expect { subject.dispatch(message) }.to throw_symbol(:something)
      end
    end

    context "when the handler returns false" do
      let(:message_subject) { "handler_that_returns_false" }

      before do
        subject.register('handler_that_returns_false')
      end

      it "should return true indicating message is good to be removed" do
        expect(subject.dispatch(message)).to be true
      end
    end
  end
end
