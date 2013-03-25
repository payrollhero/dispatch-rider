module DispatchRider
  module QueueServices
    class Base
      attr_accessor :queue

      def initialize(options = {})
        @queue = assign_storage(options.symbolize_keys)
      end

      def assign_storage(attrs)
        raise NotImplementedError
      end

      def push(item)
        message = serialize(item)
        insert(message)
        message
      end

      def insert(item)
        raise NotImplementedError
      end

      def pop(&block)
        obj = head
        if obj.message
          block.call(obj.message) && delete(obj.item)
          obj.message
        end
      end

      def head
        temp = raw_head
        OpenStruct.new(:item => temp, :message => construct_message_from(temp))
      end

      def raw_head
        raise NotImplementedError
      end

      def construct_message_from(item)
        raise NotImplementedError
      end

      def delete(item)
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
