module DispatchRider
  module QueueServices
    class ArrayQueue < Base
      def push(item)
        @queue.push(item)
        item
      end

      def pop(&block)
        message = @queue.shift
        block.call(message) if message
        message
      end

      def size
        @queue.size
      end

      protected

      def assign_storage(attrs)
        []
      end
    end
  end
end
