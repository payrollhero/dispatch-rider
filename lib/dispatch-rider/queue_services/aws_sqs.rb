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
          reactor_message = DispatchRider::Message.new(message_attributes)
          block.call(reactor_message)
          message.delete
        end
      end

      def size
        @queue.approximate_number_of_messages
      end

      protected

      def assign_storage(attrs)
        begin
          AWS::SQS.new.queues.named(attrs.fetch(:name))
        rescue NameError
          raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
        rescue IndexError
          raise RecordInvalid.new(self, ["Name can not be blank"])
        end
      end
    end
  end
end
