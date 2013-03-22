require 'spec_helper'

describe DispatchRider::QueueServices::AwsSqs do
  before do
    response = AWS::SQS::Client.new.stub_for(:get_queue_url)
    response.data[:queue_url] = "the.queue.url"
    AWS::SQS::Client.any_instance.stub(:get_queue_url).and_return(response)
  end

  subject(:queue_service) do
    DispatchRider::QueueServices::AwsSqs.new(:name => "normal_priority")
  end

  describe "#assign_storage" do
    context "when the aws gem is installed" do
      context "when the name of the queue is passed in the options" do
        it "should return an instance representing the aws sqs queue" do
          subject.assign_storage(:name => 'normal_priority')
          subject.queue.url.should eq('the.queue.url')
        end
      end

      context "when the name of the queue is not passed in the options" do
        it "should raise an exception" do
          expect { subject.assign_storage(:foo => 'bar') }.to raise_exception(DispatchRider::RecordInvalid)
        end
      end
    end
  end

  describe "#enqueue" do
    it "should push an item into the queue" do
      obj = {'subject' => 'foo', 'body' => 'bar'}.to_json
      subject.queue.should_receive(:send_message).with(obj)
      subject.enqueue(obj)
    end
  end

  describe "#dequeue" do
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
        AWS::SQS::Client.any_instance.stub(:receive_message).and_return(response)
      end

      it "should return the first item in the queue" do
        received_message = subject.dequeue

        result = JSON.parse(received_message.body)
        result['subject'].should eq('foo')
        result['body'].should eq({'bar' => 'baz'})
      end
    end

    context "when the sqs queue is empty" do
      before :each do
        subject.queue.stub!(:receive_message).and_return(nil)
      end

      it "should return nil" do
        subject.dequeue.should be_nil
      end
    end
  end

  describe "#delete_item" do
    let(:item_in_queue){ Object.new }
    it "should delete the first message from the queue" do
      item_in_queue.should_receive(:delete)
      subject.delete_item(item_in_queue)
    end
  end

  describe "#size" do
    it "should return the size of the aws queue" do
      subject.queue.should_receive(:approximate_number_of_messages)
      subject.size
    end
  end

  describe "after consuming item" do
    let(:queue_item){ OpenStruct.new(:body => {'subject' => "some_subject", 'body' => "somebody"}.to_json ) }

    def queue_service_consume_item
      queue_service.consume_item(queue_item){|message| consumption_success_status}
    end

    context "when consumption is successful" do
      let(:consumption_success_status){ true }

      it "should delete item" do
        queue_service.should_receive(:delete_item)

        queue_service_consume_item
      end
    end

    context "when consumption is not successful" do
      let(:consumption_success_status){ false }

      it "should not delete item" do
        queue_service.should_not_receive(:delete_item)

        queue_service_consume_item
      end
    end
  end

end
