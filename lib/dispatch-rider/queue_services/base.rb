module DispatchRider
  module QueueServices
    class Base
      def initialize(options = {})
        attrs = options.symbolize_keys
        @queue = assign_storage(attrs)
      end

      def push(item)
        raise NotImplementedError
      end

      def pop(&block)
        raise NotImplementedError
      end

      def empty?
        size.zero?
      end

      def size
        raise NotImplementedError
      end

      protected

      def assign_storage(attrs)
        raise NotImplementedError
      end
    end
  end
end
