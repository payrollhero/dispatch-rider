module DispatchRider
  module QueueServices
    class ArrayQueue < Base
      def assign_storage(attrs)
        []
      end

      def enqueue(item)
        queue.push(item)
      end

      def get_head
        queue.first
      end

      def dequeue(item)
        queue.delete(item)
      end

      def size
        queue.size
      end
    end
  end
end
