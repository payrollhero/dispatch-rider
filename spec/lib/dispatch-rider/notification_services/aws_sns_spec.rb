require 'spec_helper'

describe DispatchRider::NotificationServices::AwsSns do

  let(:amazon_resource_name){ "arn:aws:sns:us-west-2:123456789012:GeneralTopic" }

  subject(:aws_sns_queue) do
    DispatchRider::NotificationServices::AwsSns.new
  end

  #describe "#insert" do
    #before do
      #described_class.stub(:sns_constructor) do
        #proc { mock(:sns_adaptor, :topics => sns_topic_collection) }
      #end
    #end

    #let(:sns_topic_collection) do
      #topic_collection = mock(:sns_topic_collection)
      #topic_collection.stub(:[]){ sns_topic }
      #topic_collection
    #end
    #let(:sns_topic){ mock("AWS::SNS::Topic") }
    #let(:item) { {'subject' => 'foo', 'body' => 'bar'}.to_json }

    #it "should insert a serialized object into the queue" do
      #sns_topic.should_receive(:publish).with(item)

      #aws_sns_queue.insert(item)
    #end
  #end
end
