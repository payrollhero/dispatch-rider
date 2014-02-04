module DispatchRider
  module QueueServices
    class FileSystem < Base
      class FsReceivedMessage < ReceivedMessage
        attr_reader :queue
        
        def initialize(message, item, queue)
          @queue = queue
          super(message, item)
        end
        
        def extend_timeout(timeout)
          #file system doesn't support timeouts on items, so we ignore this.
        end
        
        def return_to_queue
          queue.put_back(item)
        end
        
      end
    end
  end
end