module DispatchRider
  module Callbacks
    class Access
      attr_reader :callbacks

      def initialize(callbacks)
        @callbacks = callbacks
      end

      def invoke(event, *args, &block)
        action_proc = block

        callbacks.for(event).reverse.each do |filter_block|
          current_action = action_proc
          action_proc = proc { filter_block.call(current_action) }
        end

        action_proc.call
      end

    end
  end
end
