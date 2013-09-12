require 'spec_helper'

describe DispatchRider::Callbacks::Storage do

  subject{ described_class.new }

  describe "#for" do
    let(:block){ "blah" }

    context "when a before callback is added as a param" do
      before :each do
        subject.before :initialize, block
      end

      example do
        subject.for(:before, :initialize).should == ["blah"]
      end

      context "and another before callback is added using a block" do
        before :each do
          subject.before :initialize do
            "woo"
          end
        end

        example do
          subject.for(:before, :initialize).count.should == 2
        end

        example do
          subject.for(:before, :initialize)[0].should == "blah"
        end

        example do
          subject.for(:before, :initialize)[1].should be_a(Proc)
        end

        example do
          subject.for(:before, :initialize)[1].call.should == "woo"
        end

        example do
          subject.for(:after, :initialize).count.should == 0
        end
      end
    end

    context "when an after callback is added as a param" do
      before :each do
        subject.after :initialize, block
      end

      example do
        subject.for(:after, :initialize).should == ["blah"]
      end

      context "and another after callback is added using a block" do
        before :each do
          subject.after :initialize do
            "woo"
          end
        end

        example do
          subject.for(:after, :initialize).count.should == 2
        end

        example do
          subject.for(:after, :initialize)[0].should == "blah"
        end

        example do
          subject.for(:after, :initialize)[1].should be_a(Proc)
        end

        example do
          subject.for(:after, :initialize)[1].call.should == "woo"
        end

        example do
          subject.for(:before, :initialize).count.should == 0
        end
      end
    end
  end

end
