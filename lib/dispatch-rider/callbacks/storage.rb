module DispatchRider
  module Callbacks
    class Storage

      def initialize
        @callbacks = {}
      end

      def before(event, block_param = nil, &block)
        block = block || block_param
        new_block = lambda do |job|
          block.call
          job.call
        end
        add_callback event, new_block
      end

      def after(event, block_param = nil, &block)
        block = block || block_param
        new_block = lambda do |job|
          job.call
          block.call
        end
        add_callback event, new_block
      end

      def around(event, block_param = nil, &block)
        block = block || block_param
        add_callback event, block
      end

      def for(event)
        @callbacks[event] || []
      end

      private

      def add_callback(event, block)
        @callbacks[event] ||= []
        @callbacks[event] << block
      end

    end
  end
end
