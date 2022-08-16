require 'spec_helper'

describe DispatchRider::QueueServices::AwsSqs do

  let(:visibility_timeout) { 100 }

  before do
    allow_any_instance_of(Aws::SQS::Client).to receive(:list_queues).and_return(OpenStruct.new({queue_urls:["the.queue.url"]}))
    allow_any_instance_of(Aws::SQS::Client).to receive(:get_queue_attributes).and_return(OpenStruct.new({attributes:{"VisibilityTimeout"=>visibility_timeout}}))
  end

  subject(:aws_sqs_queue) do
    DispatchRider::QueueServices::AwsSqs.new(:name => "normal_priority")
  end

  describe "#assign_storage" do

    context "when the aws gem is installed" do

      context "when the name of the queue is passed in the options" do
        it "should return an instance representing the aws sqs queue" do
          aws_sqs_queue.assign_storage(:name => 'normal_priority')
          expect(aws_sqs_queue.queue.url).to eq('the.queue.url')
        end
      end

      context "when the url of the queue is passed in the options" do
        it "should return an instance representing the aws sqs queue" do
          aws_sqs_queue.assign_storage(:url => 'https://sqs.us-east-1.amazonaws.com/12345/QueueName')
          expect(aws_sqs_queue.queue.url).to eq('the.queue.url')
        end
      end

      context "when neither the name nor the url of the queue is assed in the options" do
        it "should raise an exception" do
          expect { aws_sqs_queue.assign_storage(:foo => 'bar') }.to raise_exception(DispatchRider::RecordInvalid)
        end
      end
    end
  end

  describe "#insert" do
    it "should insert an item into the queue" do
      obj = { 'subject' => 'foo', 'body' => 'bar' }.to_json
      expect(aws_sqs_queue.queue).to receive(:send_message).with(obj)
      aws_sqs_queue.insert(obj)
    end
  end

  describe "#pop" do
    context "when the sqs queue has items in it" do
      let(:response_attributes) do
        {
          "SenderId" => "123456789012",
          "SentTimestamp" => Time.now.to_i.to_s,
          "ApproximateReceivedCount" => "12",
          "ApproximateFirstReceiveTimestamp" => (Time.now + 12).to_i.to_s,
        }
      end

      let(:response_message) do
        OpenStruct.new({
          message_id: "12345",
          md5_of_body: "mmmddd555",
          body: { subject: "foo", body: { bar: "baz" } }.to_json,
          receipt_handle: "HANDLE",
          attributes: response_attributes,
          visibility_timeout: visibility_timeout
        })
      end

      before do
        allow_any_instance_of(Aws::SQS::Queue).to receive(:receive_messages).and_return(OpenStruct.new({first: response_message }))
      end

      context "when the block runs faster than the timeout" do
        it "should yield the first item in the queue" do
          aws_sqs_queue.pop do |message|
            expect(message.subject).to eq('foo')
            expect(message.body).to eq('bar' => 'baz')
          end
        end
      end

      context "when the block runs slower than the timeout" do
        let(:visibility_timeout) { 1 }

        it "should raise" do
          expect {
            aws_sqs_queue.pop do |message|
              sleep(1.1)
            end
          }.to raise_exception(/message: foo,.+ took .+ seconds while the timeout was 1/)
        end
      end

    end

    context "when the sqs queue is empty" do
      before :each do
        allow_any_instance_of(Aws::SQS::Queue).to receive(:receive_messages).and_return(OpenStruct.new({first: nil }))
      end

      it "should not yield" do
        expect { |b|
          aws_sqs_queue.pop(&b)
        }.not_to yield_control
      end
    end

  end

  describe "received message methods" do
    let(:response_attributes) do
      {
        "SenderId" => "123456789012",
        "SentTimestamp" => Time.now.to_i.to_s,
        "ApproximateReceivedCount" => "12",
        "ApproximateFirstReceiveTimestamp" => (Time.now + 12).to_i.to_s,
      }
    end

    let(:response_message) do
      OpenStruct.new({
        message_id: 12345,
        md5_of_body: "mmmddd555",
        body: { subject: "foo", body: { bar: "baz" } }.to_json,
        receipt_handle: "HANDLE",
        attributes: response_attributes,
        visibility_timeout: visibility_timeout
      })
    end

    before do
      allow_any_instance_of(Aws::SQS::Queue).to receive(:receive_messages).and_return(OpenStruct.new({first: response_message }))
    end

    it "should set the visibility timeout when extend is called" do
      aws_sqs_queue.pop do |message|
        message.extend_timeout(10)
        expect(message.total_timeout).to eq(10)
        message.return_to_queue
        expect(message.total_timeout).to eq(10)
      end
    end
  end

  describe "#construct_message_from" do
    context "when the item is directly published to Aws::SQS" do
      let(:sqs_message) { OpenStruct.new(body: { 'subject' => 'foo', 'body' => 'bar' }.to_json) }

      it "should return a message" do
        result = aws_sqs_queue.construct_message_from(sqs_message)
        expect(result.subject).to eq('foo')
        expect(result.body).to eq('bar')
      end
    end

    context "when the item is published through Aws::SNS" do
      let(:sqs_message) do
        message = { 'subject' => 'foo', 'body' => 'bar' }
        body = { "Type" => "Notification", "Message" => message.to_json }.to_json
        OpenStruct.new(body: body)
      end

      it "should return a message" do
        result = aws_sqs_queue.construct_message_from(sqs_message)
        expect(result.subject).to eq('foo')
        expect(result.body).to eq('bar')
      end
    end
  end

  describe "#delete" do
    let(:item_in_queue) { Object.new }

    it "should delete the first message from the queue" do
      expect(item_in_queue).to receive(:delete)
      aws_sqs_queue.delete(item_in_queue)
    end
  end

  describe "#size" do
    it "should return the size of the aws queue" do
      expect(aws_sqs_queue.queue).to receive(:approximate_number_of_messages)
      aws_sqs_queue.size
    end
  end
end
