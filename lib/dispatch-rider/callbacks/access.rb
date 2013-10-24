module DispatchRider
  module Callbacks
    class Access
      attr_reader :callbacks

      def initialize(callbacks)
        @callbacks = callbacks
      end

      def invoke(event, *args, &block)
        begin
          invoke_callbacks :before, event, *args
          invoke_callbacks :around, event, *args, &block
        ensure
          invoke_callbacks :after, event, *args
        end
      end

      private

      def invoke_callbacks(modifier, event, *args, &block)
        _callbacks = callbacks.for(modifier, event).each do |callback|
          callback.call(*args, block)
        end
        block.call if _callbacks.empty? && block
      end

    end
  end
end
