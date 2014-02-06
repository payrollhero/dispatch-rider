# This is a rudementary queue service that uses file system instead of
# AWS::SQS or SimpleQueue. It addresses SimpleQueue's inability to be used
# by only one application instance while avoiding the cost of setting up AWS::SQS.
# This is ideal to be used in development mode between multiple applications.
module DispatchRider
  module QueueServices
    require "dispatch-rider/queue_services/file_system/queue"
    require "dispatch-rider/queue_services/file_system/fs_received_message"
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
      
      def received_message_for(raw_item)
         FsReceivedMessage.new(construct_message_from(raw_item), raw_item, queue)
      end

      def construct_message_from(item)
        deserialize(item.read)
      end
      
      def put_back(item)
        queue.put_back(item)
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
