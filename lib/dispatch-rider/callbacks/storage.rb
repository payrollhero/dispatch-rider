# frozen_string_literal: true

module DispatchRider
  module Callbacks
    # Storage for callbacks.
    class Storage
      def initialize
        @callbacks = Hash.new { |storage, key| storage[key] = [] }
      end

      # @param [Symbol] event name of the event
      # @param [#call] block_param block passed as a parameter
      # @param [Proc] &block
      def before(event, block_param = nil, &block)
        around(event) do |job, *args|
          (block_param || block).call(*args)
          job.call
        end
      end

      # @param [Symbol] event name of the event
      # @param [#call] block_param block passed as a parameter
      # @param [Proc] &block
      def after(event, block_param = nil, &block)
        around(event) do |job, *args|
          begin
            job.call
          ensure
            (block_param || block).call(*args)
          end
        end
      end

      # @param [Symbol] event name of the event
      # @param [#call] block_param block passed as a parameter
      # @param [Proc] &block
      def around(event, block_param = nil, &block)
        @callbacks[event] << (block_param || block)
      end

      # @param [Symbol] event name of the event
      def for(event)
        @callbacks[event]
      end
    end
  end
end
