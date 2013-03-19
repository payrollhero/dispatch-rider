require 'spec_helper'

describe DispatchRider::Publisher, :nodb => true do
  let(:queue) { DispatchRider::QueueServices::ArrayQueue.new }

  subject do
    DispatchRider::Publisher.new(queue)
  end

  describe "#publish" do
    it "should push message to queue" do
      subject.publish(:subject => "do_what", :body => {:text => "simple instruction"})
      message = subject.instance_variable_get('@queue').pop {|msg| msg}
      message.subject.should eq("do_what")
      message.body.should eq({:text => "simple instruction"})
    end
  end
end
