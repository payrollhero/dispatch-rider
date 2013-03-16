require 'spec_helper'

describe DispatchRider::Publisher, :nodb => true do

  let :queue do
    []
  end

  subject do
    DispatchRider::Publisher.new(queue)
  end

  describe "init" do

    it "should instantiate with a queue as a parameter" do
      queue = []
      instance = DispatchRider::Publisher.new(queue)
      instance.instance_variable_get("@queue").should === queue
    end

  end

  describe "#publish" do

    it "should push message to queue" do
      subject.publish(:subject => "do_what", :body => {:this => "simple instruction"})
      queue.should include DispatchRider::Message.new(:subject => "do_what", :body => {:this => "simple instruction"})
    end

  end

end
