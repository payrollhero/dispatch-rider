# This queue service is based on aws sqs.
# To make this queue service work, one would need the aws sqs gem to be installed.
module DispatchRider
  module QueueServices
    class AwsSqs < Base
      require "dispatch-rider/queue_services/aws_sqs/message_body_extractor"

      def assign_storage(attrs)
        begin
          sqs = AWS::SQS.new(:logger => nil)
          if attrs[:name]
            sqs.queues.named(attrs[:name])
          elsif attrs[:url]
            sqs.queues[attrs[:url]]
          else
            raise RecordInvalid.new(self, ["Either name or url have to be specified"])
          end
        rescue NameError
          raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
        end
      end

      def insert(item)
        queue.send_message(item)
      end

      def raw_head
        queue.receive_message
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
    end
  end
end
