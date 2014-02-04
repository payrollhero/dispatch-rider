require 'spec_helper'

describe DispatchRider::Handlers::Base do
  class NoProcessImplemented < DispatchRider::Handlers::Base
  end

  class ProcessImplemented < DispatchRider::Handlers::Base
    def process(options)
      "good job"
    end
  end
  
  class ProcessWithImmediateRetry < DispatchRider::Handlers::Base
    def process(options)
      raise "I have failed!"
    end
    
    def retry_timeout; :immediate; end
  end
  
  class ProcessWithTenSecondRetry < DispatchRider::Handlers::Base
    def process(options)
      raise "I have failed!"
    end
    
    def retry_timeout; 10*60; end
  end

  describe "#do_process" do
    let(:message){ double(:message) {}}
    before { message.stub(:body) {}}
    
    context "when class doesn't implement process" do
      let(:handler){ NoProcessImplemented.new }

      example do
        expect {
          handler.do_process(message)
        }.to raise_exception NotImplementedError, "Method 'process' not overridden in subclass!"
      end
    end

    context "when the class does implement process" do
      let(:handler){ ProcessImplemented.new }

      example do
        expect {
          handler.do_process(message)
        }.to_not raise_exception
      end

      example do
        handler.do_process(message).should == "good job"
      end
    end
    
    context "when the class wants to immediately retry" do
      let(:handler) { ProcessWithImmediateRetry.new }
      
      example do
        message.should_receive(:return_to_queue)
        
        expect {
          handler.do_process(message)
        }.to raise_exception "I have failed!"
      end
    end
    
    context "when the class wants to retry in 10 seconds" do
      let(:handler) { ProcessWithTenSecondRetry.new }
      
      example do
        message.should_receive(:extend_timeout).with(10*60)
        
        expect {
          handler.do_process(message)
        }.to raise_exception "I have failed!"
      end
    end
  end

end
