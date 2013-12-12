# This queue service is based on aws sqs.
# To make this queue service work, one would need the aws sqs gem to be installed.
module DispatchRider
  module QueueServices
    class AwsSqs < Base
      require "dispatch-rider/queue_services/aws_sqs/message_body_extractor"

      class AbortExecution < RuntimeError; end
      class VisibilityTimeoutExceeded < RuntimeError; end

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

      def pop(&block)
        begin
          queue.receive_message do |raw_item|
            obj = OpenStruct.new(:item => raw_item, :message => construct_message_from(raw_item))

            visibility_timout_shield(obj.message) do
              raise AbortExecution, "false received from handler" unless block.call(obj.message)
              obj.message
            end

          end
        rescue AbortExecution
          # ignore, it was already handled, just need to break out if pop
        end
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

      def visibility_timeout
        queue.visibility_timeout
      end

      def visibility_timout_shield(message)
        start_time = Time.now
        timeout = visibility_timeout # capture it at start
        begin
          yield
        ensure
          duration = Time.now - start_time
          raise VisibilityTimeoutExceeded, "message: #{message.subject}, #{message.body.inspect} took #{duration} seconds while the timeout was #{timeout}" if duration > timeout
        end
      end

    end
  end
end
