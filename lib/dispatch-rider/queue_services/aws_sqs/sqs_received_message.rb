module DispatchRider
  module QueueServices
    class AwsSqs < Base
      class SqsReceivedMessage < ReceivedMessage
        attr_reader :total_timeout, :start_time
        
        def initialize(message, raw_item, queue)
          @total_timeout = queue.visibility_timeout
          @start_time = Time.now
          super(message, raw_item)
        end
        
        # NOTE: Setting the visibility timeout resets the timeout to NOW and makes it visibility timeout this time
        # Essentially resetting the timer on this message
        def extend_timeout(timeout)
          item.visibility_timeout = timeout
          if timeout > 0
            @total_timeout = timeout + (Time.now - start_time).to_i
          end
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
          queue.arn.split(':').last
        end

      end
    end
  end
end
