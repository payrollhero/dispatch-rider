# This queue service is based on aws sqs.
# To make this queue service work, one would need the aws sqs gem to be installed.
module DispatchRider
  module QueueServices
    class AwsSqs < Base
      require "dispatch-rider/queue_services/aws_sqs/message_body_extractor"
      require "dispatch-rider/queue_services/aws_sqs/sqs_received_message"

      class AbortExecution < RuntimeError; end
      class VisibilityTimeoutExceeded < RuntimeError; end

      def assign_storage(attrs)
        begin
          sqs = Aws::SQS::Client.new(logger: nil)
          if attrs[:name].present?
            url = sqs.list_queues({queue_name_prefix: attrs[:name]}).queue_urls.first
            set_visibility_timeout(sqs,url)
            Aws::SQS::Queue.new(url: url, client: sqs)
          elsif attrs[:url].present?
            set_visibility_timeout(sqs,attrs[:url])
            Aws::SQS::Queue.new(url: attrs[:url], client: sqs)
          else
            raise RecordInvalid.new(self, ["Either name or url have to be specified"])
          end
        rescue NameError
          raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
        end
      end

      def pop
        raw_item = queue.receive_messages({max_number_of_messages: 1}).first
        if raw_item.present?
          obj = SqsReceivedMessage.new(construct_message_from(raw_item), raw_item, queue, visibility_timeout)

          visibility_timeout_shield(obj) do
            raise AbortExecution, "false received from handler" unless yield(obj)
            obj
          end

          Retriable.retriable(tries: 3) { raw_item.delete }
        end
      rescue AbortExecution
        # ignore, it was already handled, just need to break out if pop
      end

      def insert(item)
        queue.send_message(item)
      end

      def construct_message_from(item)
        deserialize(MessageBodyExtractor.new(item).extract)
      end

      def delete(item)
        item.delete
      end

      def size
        queue.approximate_number_of_messages
      end

      attr_reader :visibility_timeout

      private

      def set_visibility_timeout(client,url)
        resp = client.get_queue_attributes(queue_url: url, attribute_names: ["VisibilityTimeout"])
        @visibility_timeout = resp.attributes["VisibilityTimeout"]
      end

      def visibility_timeout_shield(message)
        begin
          yield
        ensure
          duration = Time.now - message.start_time
          timeout = message.total_timeout
          raise VisibilityTimeoutExceeded, "message: #{message.subject}, #{message.body.inspect} took #{duration} seconds while the timeout was #{timeout}" if duration > timeout
        end
      end

    end
  end
end
