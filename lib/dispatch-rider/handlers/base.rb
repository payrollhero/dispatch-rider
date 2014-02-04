module DispatchRider
  module Handlers
    class Base
      include NamedProcess
      extend InheritanceTracking
      
      attr_reader :raw_message

      def do_process(raw_message)
        with_named_process(self.class.name) do
          @raw_message = raw_message
          process(raw_message.body)
        end
      rescue Exception => e
        self.retry if self.retry_on_failure?
        raise e
      end

      def process(message)
        raise NotImplementedError, "Method 'process' not overridden in subclass!"
      end
      
      protected
      
      def extend_timeout(timeout)
        raw_message.extend_timeout(timeout)
      end
      
      def return_to_queue
        raw_message.return_to_queue
      end
      
      def retry
        timeout = retry_timeout
        case timeout
        when :immediate
          return_to_queue
        else
          extend_timeout(timeout)
        end
      end
      
      def retry_on_failure?
        self.respond_to? :retry_timeout
      end
    end
  end
end
