module DispatchRider
  module QueueServices
    class AwsSqs < Base
      class SqsReceivedMessage < ReceivedMessage
        def extend_timeout(timeout)
          item.visibility_timeout = timeout
        end
        
        #We effectively return the item to the queue by setting
        #the visibility timeout to zero.  The item
        #should become immediately visible.
        #The next receiver will reset the visibility
        #to something appropriate
        def return_to_queue
          extend_timeout(0)
        end
        
      end
    end
  end
end
