require 'delegate'

module DispatchRider
  module QueueServices
    class ReceivedMessage < ::SimpleDelegator

      #Item is the raw message item as returned by the queue implementor
      #it's contents will depend on the queue being used
      attr_reader :item

      def initialize(message, item)
        @item = item
        super(message)
      end

      def guid
        self.body['guid']
      end

      def extend_timeout(time)
        raise NotImplementedError
      end

      def return_to_queue
        raise NotImplementedError
      end

      def receive_count
        raise NotImplementedError
      end

      def sent_at
        raise NotImplementedError
      end

      def queue_name
        raise NotImplementedError
      end

    end
  end
end
