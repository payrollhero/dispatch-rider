require 'spec_helper'

describe DispatchRider::QueueServices::ArrayQueue do
  let( :queue_content ){ subject.instance_variable_get("@queue") }

  let( :item ){ DispatchRider::Message.new("subject" => "do", "body" => { "what" => "exactly" } ) }

  describe "#push" do
    it "should push item to the queue" do
      subject.push item
      queue_content.should include item
    end
  end

  describe "#pop" do
    context "when there is nothing in queue" do
      before { queue_content.clear }

      it "should pop item to the queue" do
        popped_item = subject.pop
        popped_item.should be_nil
        queue_content.should be_empty
      end
    end

    context "when when an item is in queue" do
      before { queue_content << item }

      it "should pop item to the queue" do
        subject.pop do |popped_item|
          popped_item.should == item
          queue_content.should be_empty
        end
      end
    end
  end

  describe "#size" do
    context "when there is nothing in queue" do
      before { queue_content.clear }

      example{ subject.size.should be_zero }
    end

    context "when when an item is in queue" do
      before { queue_content << item }

      example{ subject.size.should == 1 }
    end
  end

  describe "#empty?" do
    context "when there is nothing in queue" do
      before { queue_content.clear }

      example{ subject.should be_empty }
    end

    context "when when an item is in queue" do
      before { queue_content << item }

      example{ subject.should_not be_empty }
    end
  end
end
