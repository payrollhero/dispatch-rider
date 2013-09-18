require 'spec_helper'

describe DispatchRider::Handlers::Base do
  class NoProcessImplemented < DispatchRider::Handlers::Base
  end

  class ProcessImplemented < DispatchRider::Handlers::Base
    def process(options)
      "good job"
    end
  end

  describe "#do_process" do
    context "when class doesn't implement process" do
      let(:handler){ NoProcessImplemented.new }

      example do
        expect {
          handler.do_process({})
        }.to raise_exception NotImplementedError, "Method 'process' not overridden in subclass!"
      end
    end

    context "when the class does implement process" do
      let(:handler){ ProcessImplemented.new }

      example do
        expect {
          handler.do_process({})
        }.to_not raise_exception
      end

      example do
        handler.do_process({}).should == "good job"
      end
    end
  end

end
