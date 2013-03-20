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

  describe "#get_head" do
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

      it "should return the first message in the queue" do
        result = JSON.parse(subject.get_head)
        result['subject'].should eq('foo')
        result['body'].should eq({'bar' => 'baz'})
      end
    end

    context "when the sqs queue is empty" do
      before :each do
        subject.queue.stub!(:receive_message).and_return(nil)
      end

      it "should return nil" do
        subject.get_head.should be_nil
      end
    end
  end

  describe "#dequeue" do
    it "should delete the first message from the queue" do
      obj = OpenStruct.new(:delete => nil)
      subject.queue.should_receive(:receive_message).and_return(obj)
      obj.should_receive(:delete)
      subject.dequeue
    end
  end

  describe "#size" do
    it "should return the size of the aws queue" do
      subject.queue.should_receive(:approximate_number_of_messages)
      subject.size
    end
  end
end
