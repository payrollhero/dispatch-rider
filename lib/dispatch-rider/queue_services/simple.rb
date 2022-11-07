# frozen_string_literal: true

# This is a simple implementation of an in memory queue using an array.
module DispatchRider
  module QueueServices
    class Simple < Base
      def assign_storage(attrs)
        []
      end

      def insert(item)
        queue << item
      end

      def raw_head
        queue.first
      end

      def construct_message_from(item)
        deserialize(item)
      end

      delegate :delete, to: :queue

      delegate :size, to: :queue
    end
  end
end
