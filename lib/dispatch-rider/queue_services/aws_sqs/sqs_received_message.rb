# frozen_string_literal: true

module DispatchRider
  module QueueServices
    class AwsSqs < Base
      class SqsReceivedMessage < ReceivedMessage
        attr_reader :total_timeout, :start_time

        def initialize(message, raw_item, queue, queue_visibility_timeout)
          @queue = queue
          @total_timeout = queue_visibility_timeout.to_i
          @start_time = Time.now
          super(message, raw_item)
        end

        # NOTE: Setting the visibility timeout resets the timeout to NOW and makes it visibility timeout this time
        # Essentially resetting the timer on this message
        def extend_timeout(timeout)
          item.change_visibility({
            visibility_timeout: timeout # required
          })
          @total_timeout = timeout + (Time.now - start_time).to_i if timeout.positive?
        end

        # We effectively return the item to the queue by setting
        # the visibility timeout to zero.  The item
        # should become immediately visible.
        # The next receiver will reset the visibility
        # to something appropriate
        def return_to_queue
          extend_timeout(0)
        end

        def receive_count
          @item.approximate_receive_count
        end

        def sent_at
          @item.sent_timestamp
        end

        def queue_name
          @item.queue_arn.split(':').last
        end
      end
    end
  end
end
