module DispatchRider
  module QueueServices
    class AwsSqs < Base
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

      def size
        @queue.approximate_number_of_messages
      end

      protected

      def assign_storage(attrs)
        AWS::SQS.new.queues.named(attrs.fetch(:queue_name))
      end
    end
  end
end
