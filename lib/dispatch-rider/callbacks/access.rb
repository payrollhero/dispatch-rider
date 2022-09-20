# frozen_string_literal: true

module DispatchRider
  module Callbacks
    # Provides access for invoking callbacks.
    class Access
      attr_reader :callbacks

      def initialize(callbacks)
        @callbacks = callbacks
      end

      # Executes the passed block wrapped in the event's callbacks.
      # @param [Symbol] event
      # @param [Array] args
      # @param [Proc] block
      def invoke(event, *args, &block)
        stack_of_callbacks = callbacks.for(event).reverse

        block_with_callbacks = stack_of_callbacks.reduce(block) { |inner_block, outer_block|
          -> { outer_block.call(inner_block, *args) }
        }

        block_with_callbacks.call
      end
    end
  end
end
