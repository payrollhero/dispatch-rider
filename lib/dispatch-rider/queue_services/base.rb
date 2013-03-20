module DispatchRider
  module QueueServices
    class Base
      attr_accessor :queue

      def initialize(options = {})
        attrs = options.symbolize_keys
        @queue = assign_storage(attrs)
      end

      def assign_storage(attrs)
        raise NotImplementedError
      end

      def push(item)
        message = serialize(item)
        enqueue(message)
        message
      end

      def enqueue(item)
        raise NotImplementedError
      end

      def pop(&block)
        message = get_head
        if message
          message = deserialize(message)
          block.call(message) && dequeue
        end
        message
      end

      def get_head
        raise NotImplementedError
      end

      def dequeue
        raise NotImplementedError
      end

      def empty?
        size.zero?
      end

      def size
        raise NotImplementedError
      end

      protected

      def serialize(item)
        item.to_json
      end

      def deserialize(item)
        attrs = JSON.parse(item).symbolize_keys
        DispatchRider::Message.new(attrs)
      end
    end
  end
end
