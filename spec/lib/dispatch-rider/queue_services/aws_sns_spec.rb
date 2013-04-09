require 'spec_helper'

describe DispatchRider::QueueServices::AwsSns do

  before do
    AWS::Core::Configuration.new({
      :stub_requests => true,
      :access_key_id => 'ACCESS_KEY_ID',
      :secret_access_key => 'SECRET_ACCESS_KEY',
      :session_token => 'SESSION_TOKEN'
    })
  end

  let(:amazon_resource_name){ "arn:aws:sns:us-west-2:123456789012:GeneralTopic" }

  subject(:aws_sns_queue) do
    DispatchRider::QueueServices::AwsSns.new name: amazon_resource_name
  end

  describe "#assign_storage" do
    it "should return an empty array" do
      aws_sns_queue.assign_storage(name: amazon_resource_name).should be_a AWS::SNS::Topic
    end
  end

  describe "#insert" do
    let(:item) { {'subject' => 'foo', 'body' => 'bar'}.to_json }
    let(:response) { AWS::SNS::Client.new.stub_for(:publish) }

    it "should insert a serialized object into the queue" do
      AWS::SNS::Client.any_instance.should_receive(:publish).with({
        :message => {:default => item }.to_json,
        :message_structure => 'json',
        :topic_arn => amazon_resource_name,
      }).and_return(response)

      aws_sns_queue.insert( item )
    end
  end

  describe "#raw_head" do
    it { expect{ aws_sns_queue.raw_head }.to raise_error NotImplementedError }
  end

  describe "#construct_message_from" do
    it { expect{ aws_sns_queue.raw_head }.to raise_error NotImplementedError }
  end

  describe "#delete" do
    it { expect{ aws_sns_queue.raw_head }.to raise_error NotImplementedError }
  end

  describe "#size" do
    it { expect{ aws_sns_queue.raw_head }.to raise_error NotImplementedError }
  end
end
