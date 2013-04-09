# This is a rudementary queue service that uses file system instead of
# AWS::SQS or SimpleQueue. It addresses SimpleQueue's inability to be used
# by only one application instance while avoid the cost of setting up AWS::SQS.
# This is ideal to be used inside development.

module DispatchRider
  module QueueServices
    require "dispatch-rider/queue_services/file_system/queue"
    class FileSystem < Base
      def assign_storage(attrs)
        begin
          path = attrs.fetch(:path)
          Queue.new(path)
        rescue IndexError
          raise RecordInvalid.new(self, ["Path can not be blank"])
        end
      end

      def insert(item)
        queue.add item
      end

      def raw_head
        queue.pop
      end

      def construct_message_from(item)
        deserialize(item.read) if item
      end

      def delete(item)
        queue.remove item
      end

      def size
        queue.size
      end
    end
  end
end
