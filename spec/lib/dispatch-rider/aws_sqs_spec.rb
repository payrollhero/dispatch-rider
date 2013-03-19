require 'spec_helper'

describe DispatchRider::QueueServices::AwsSqs do
  before do
    response = AWS::SQS::Client.new.stub_for(:get_queue_url)
    response.data[:queue_url] = "the.queue.url"
    AWS::SQS::Client.any_instance.stub(:get_queue_url).and_return(response)
  end

  subject do
    DispatchRider::QueueServices::AwsSqs.new(:name => "normal_priority")
  end

  describe "#initialize" do
    context "when all the required params are passed in" do
      subject do
        DispatchRider::QueueServices::AwsSqs.new(:name => "normal_priority")
      end

      it "should set the queue to AWS SQS" do
        subject.instance_variable_get("@queue").should be_kind_of AWS::SQS::Queue
      end
    end
  end

  describe "#push" do # wrapper for AWS::SQS::Queue#send_message
    let(:send_message_response) do
      response = AWS::SQS::Client.new.stub_for(:send_message)
      response.data[:message_id] = 12345
      response.data[:md5_of_message_body] = "mmmddd555"
      response
    end
    let(:message_subject){ "directive" }
    let(:message_body){ {"move_to" => "rally point a"} }

    it "should send the message through AWS::SQS::Client" do
      AWS::SQS::Client.any_instance.stub(:send_message) do |message|
        message[:queue_url].should == "the.queue.url"
        JSON.parse(message[:message_body]).should == {
          "subject" => message_subject,
          "body" => message_body,
        }
        send_message_response
      end
      sent_message = subject.push DispatchRider::Message.new({
        "subject" => message_subject,
        "body" => message_body,
      })
    end
  end

  describe "#pop" do # wrapper for AWS::SQS::Queue#receive_message
    let(:response_message) {{
      :message_id => 12345,
      :md5_of_body => "mmmddd555",
      :body => {:subject => "directive", :body => {:move_to => "rally point a"}}.to_json,
      :receipt_handle => "HANDLE",
      :attributes => response_attributes,
    }}
    let(:response_attributes) {{
      "SenderId" => "123456789012",
      "SentTimestamp" => Time.now.to_i.to_s,
      "ApproximateReceivedCount" => "12",
      "ApproximateFirstReceiveTimestamp" => (Time.now + 12).to_i.to_s,
    }}

    before do
      response = AWS::SQS::Client.new.stub_for(:receive_message)
      response.data[:messages] = [response_message]
      AWS::SQS::Client.any_instance.stub(:receive_message).and_return(response)
      AWS::SQS::Client.any_instance.stub(:delete_message).and_return(AWS::SQS::Client.new.stub_for(:delete_message))
    end

    it "should return a message with correct subject and body" do
      subject.pop do |received_message|
        received_message.should be_kind_of DispatchRider::Message
        received_message.subject.should == "directive"
        received_message.body.should == { "move_to" => "rally point a" }
      end
    end
  end
end
