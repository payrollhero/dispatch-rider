module DispatchRider
  module QueueServices
    class ArrayQueue

      def initialize(options = {})
        assign_storage
      end

      def push(item)
        @queue.push(item)
      end

      def pop(&block)
        message = @queue.shift
        block.call(message) if message
      end

      def empty?
        @queue.empty?
      end

      def size
        @queue.size
      end

      private

      def assign_storage
        @queue = []
      end
    end
  end
end
