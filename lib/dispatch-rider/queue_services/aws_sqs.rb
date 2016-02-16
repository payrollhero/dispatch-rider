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
          sqs = AWS::SQS.new(logger: nil, region: attrs[:region])
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

      def pop
        raw_item = queue.receive_message
        if raw_item.present?
          obj = SqsReceivedMessage.new(construct_message_from(raw_item), raw_item, queue)

          visibility_timeout_shield(obj) do
            raise AbortExecution, "false received from handler" unless yield(obj)
            obj
          end

          with_retries(max_tries: 3) do
            raw_item.delete
          end
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

      private

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
