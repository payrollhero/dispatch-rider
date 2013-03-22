module DispatchRider
  module QueueServices
    class RegularQueue < Base
      def assign_storage(attrs)
        Queue.new
      end

      def enqueue(item)
        queue.enq(item)
      end

      def dequeue
        queue.deq(true)
      end

      def size
        queue.size
      end
    end
  end
end
