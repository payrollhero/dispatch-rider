# frozen_string_literal: true

module DispatchRider
  module Handlers
    class Base
      include NamedProcess
      extend InheritanceTracking

      class << self
        def set_default_retry( amount )
          define_method(:retry_timeout) do
            amount
          end
        end
      end

      attr_reader :raw_message

      def do_process(raw_message)
        with_named_process(raw_message) do
          @raw_message = raw_message
          process(raw_message.body)
        end
      rescue Exception => e
        self.retry if retry_on_failure?
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
        respond_to? :retry_timeout
      end
    end
  end
end
