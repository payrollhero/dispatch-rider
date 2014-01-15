# This is the base class that provides the template for all queue services.
# The child classes must implement the following methods to become a concrete class :
# assign_storage, insert, raw_head, construct_message_from, delete and size.
# The instances of this class or it's child classes are supposed to perform the following actions on the queue service :
# initialize, push, pop and empty?
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
        if obj
          block.call(obj.message) && delete(obj.item)
          obj.message
        end
      end

      def head
        raw_item = raw_head
        raw_item && ::OpenStruct.new(:item => raw_item, :message => construct_message_from(raw_item))
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
