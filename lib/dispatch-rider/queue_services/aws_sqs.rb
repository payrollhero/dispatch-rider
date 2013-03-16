module DispatchRider
  module QueueServices
    class AwsSqs

      def initialize(queue_name)
        assign_storage(queue_name)
      end

      def push(item)
        @queue.send_message(item.to_json)
        item
      end

      def pop(&block)
        message = @queue.receive_message

        if message
          message_attributes = JSON.parse(message.body)
          reactor_message    = DispatchRider::Message.new(message_attributes)

          block.call(reactor_message)

          message.delete
        end
      end

      def empty?
        size.zero?
      end

      def size
        @queue.approximate_number_of_messages
      end

      private

      def assign_storage(queue_name)
        @queue = AWS::SQS.new.queues.named(queue_name)
      end
    end
  end
end
