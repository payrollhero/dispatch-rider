module DispatchRider
  module QueueServices
    class Base
      attr_accessor :queue

      include ActiveSupport::Callbacks

      define_callbacks :consume_item

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
        item = dequeue
        consume_item(item, &block) if item
      end

      def dequeue
        raise NotImplementedError
      end

      def consume_item(item, &block)
        callback_info = OpenStruct.new(:item => item, :success => nil)

        run_callbacks :consume_item, callback_info do
          message = deserialize(item)
          callback_info.success = block.call(message)
          message
        end
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

      private

      def run_after_consume_callbacks_for(item)
        self.class.after_consume_callbacks.each do |callback_method_name|
          send callback_method_name, item
        end
      end
    end
  end
end
