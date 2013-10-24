module DispatchRider
  module Callbacks
    class Storage

      def initialize
        @callbacks = {}
      end

      def before(event, block_param = nil, &block)
        add_callback :before, event, block_param, &block
      end

      def after(event, block_param = nil, &block)
        add_callback :after, event, block_param, &block
      end

      def around(event, block_param = nil, &block)
        add_callback :around, event, block_param, &block
      end

      def for(modifier, event)
        @callbacks[[modifier, event]] || []
      end

      private

      def add_callback(modifier, event, block_param = nil, &block)
        block = block || block_param
        @callbacks[[modifier, event]] ||= []
        @callbacks[[modifier, event]] << block
      end

    end
  end
end
