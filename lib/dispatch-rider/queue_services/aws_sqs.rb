module DispatchRider
  module QueueServices
    class AwsSqs < Base
      set_callback :consume_item, :after, :handle_consumed_item

      def assign_storage(attrs)
        begin
          AWS::SQS.new.queues.named(attrs.fetch(:name))
        rescue NameError
          raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
        rescue IndexError
          raise RecordInvalid.new(self, ["Name can not be blank"])
        end
      end

      def enqueue(item)
        queue.send_message(item)
      end

      def dequeue
        queue.receive_message
      end

      def delete_item(item)
        item.delete
      end

      def size
        queue.approximate_number_of_messages
      end

      def handle_consumed_item(callback_info)
        delete_item(callback_info.item) if callback_info.success
      end

      def deserialize(item)
        super(item.body)
      end
    end
  end
end
