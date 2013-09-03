require 'spec_helper'

describe DispatchRider::QueueServices::AwsSqs do
  before do
    AWS.config(stub_requests: true)
    response = AWS::SQS::Client.new.stub_for(:get_queue_url)
    response.data[:queue_url] = "the.queue.url"
    AWS::SQS::Client.any_instance.stub(:client_request).and_return(response)
  end

  subject(:aws_sqs_queue) do
    DispatchRider::QueueServices::AwsSqs.new(:name => "normal_priority")
  end

  describe "#assign_storage" do
    context "when the aws gem is installed" do
      context "when the name of the queue is passed in the options" do
        it "should return an instance representing the aws sqs queue" do
          aws_sqs_queue.assign_storage(:name => 'normal_priority')
          aws_sqs_queue.queue.url.should eq('the.queue.url')
        end
      end

      context "when the name of the queue is not passed in the options" do
        it "should raise an exception" do
          expect { aws_sqs_queue.assign_storage(:foo => 'bar') }.to raise_exception(DispatchRider::RecordInvalid)
        end
      end
    end
  end

  describe "#insert" do
    it "should insert an item into the queue" do
      obj = {'subject' => 'foo', 'body' => 'bar'}.to_json
      aws_sqs_queue.queue.should_receive(:send_message).with(obj)
      aws_sqs_queue.insert(obj)
    end
  end

  describe "#raw_head" do
    context "when the sqs queue has items in it" do
      let(:response_attributes) {{
        "SenderId" => "123456789012",
        "SentTimestamp" => Time.now.to_i.to_s,
        "ApproximateReceivedCount" => "12",
        "ApproximateFirstReceiveTimestamp" => (Time.now + 12).to_i.to_s,
      }}

      let(:response_message) { {
        :message_id => 12345,
        :md5_of_body => "mmmddd555",
        :body => {:subject => "foo", :body => {:bar => "baz"}}.to_json,
        :receipt_handle => "HANDLE",
        :attributes => response_attributes,
      } }

      before :each do
        response = AWS::SQS::Client.new.stub_for(:receive_message)
        response.data[:messages] = [response_message]
        AWS::SQS::Client::V20121105.any_instance.stub(:receive_message).and_return(response)
        AWS::SQS::Queue.any_instance.stub(:verify_receive_message_checksum).and_return([])
      end

      it "should return the first item in the queue" do
        received_message = aws_sqs_queue.raw_head
        result = JSON.parse(received_message.body)
        result['subject'].should eq('foo')
        result['body'].should eq({'bar' => 'baz'})
      end
    end

    context "when the sqs queue is empty" do
      before :each do
        aws_sqs_queue.queue.stub(:receive_message).and_return(nil)
      end

      it "should return nil" do
        aws_sqs_queue.raw_head.should be_nil
      end
    end
  end

  describe "#construct_message_from" do
    context "when the item is directly published to AWS::SQS" do
      let(:sqs_message){ OpenStruct.new(:body => {'subject' => 'foo', 'body' => 'bar'}.to_json) }

      it "should return a message" do
        result = aws_sqs_queue.construct_message_from(sqs_message)
        result.subject.should eq('foo')
        result.body.should eq('bar')
      end
    end

    context "when the item is published through AWS::SNS" do
      let(:sqs_message){ OpenStruct.new(:body => {"Type" => "Notification", "Message" => {'subject' => 'foo', 'body' => 'bar'}.to_json}.to_json) }

      it "should return a message" do
        result = aws_sqs_queue.construct_message_from(sqs_message)
        result.subject.should eq('foo')
        result.body.should eq('bar')
      end
    end
  end

  describe "#delete" do
    let(:item_in_queue){ Object.new }

    it "should delete the first message from the queue" do
      item_in_queue.should_receive(:delete)
      aws_sqs_queue.delete(item_in_queue)
    end
  end

  describe "#size" do
    it "should return the size of the aws queue" do
      aws_sqs_queue.queue.should_receive(:approximate_number_of_messages)
      aws_sqs_queue.size
    end
  end
end
