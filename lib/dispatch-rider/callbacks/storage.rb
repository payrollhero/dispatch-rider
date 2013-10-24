module DispatchRider
  module Callbacks
    class Storage

      def initialize
        @callbacks = {}
      end

      def before(event, block_param = nil, &block)
        around(event) do |job, *args|
          (block_param || block).call(*args)
          job.call
        end
      end

      def after(event, block_param = nil, &block)
        around(event) do |job, *args|
          job.call
          (block_param || block).call(*args)
        end
      end

      def around(event, block_param = nil, &block)
        @callbacks[event] ||= []
        @callbacks[event] << (block_param || block)
      end

      def for(event)
        @callbacks[event] || []
      end

    end
  end
end
