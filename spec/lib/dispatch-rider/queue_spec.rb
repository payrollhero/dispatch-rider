require 'spec_helper'

describe DispatchRider::Queue, :nodb => true do

  subject do
    DispatchRider::Queue
  end

  describe ".build" do
    it "requires :queue_service" do
      expect do
        subject.build({})
      end.to raise_exception(ArgumentError, /queue_service/)
    end
    context "queue_service = 'array'" do
      it "should return an instance of ArrayQueue" do
        object = subject.build(:queue_service => 'array')
        object.should be_kind_of(DispatchRider::QueueServices::ArrayQueue)
      end
    end
    context "queue_service = :array" do
      it "should return an instance of ArrayQueue" do
        object = subject.build(:queue_service => :array)
        object.should be_kind_of(DispatchRider::QueueServices::ArrayQueue)
      end
    end
    context "queue_service = 'aws_sqs'" do
      before do
        DispatchRider::QueueServices::AwsSqs.any_instance.stub(:assign_storage)
      end
      it "should return an instance of AwsSqs" do
        object = subject.build(:queue_service => 'aws_sqs', :queue_name => "standard_priority")
        object.should be_kind_of(DispatchRider::QueueServices::AwsSqs)
      end
    end
    context "queue_service = :aws_sqs" do
      before do
        DispatchRider::QueueServices::AwsSqs.any_instance.stub(:assign_storage)
      end
      it "should return an instance of AwsSqs" do
        object = subject.build(:queue_service => :aws_sqs, :queue_name => "standard_priority")
        object.should be_kind_of(DispatchRider::QueueServices::AwsSqs)
      end
    end
  end

end
