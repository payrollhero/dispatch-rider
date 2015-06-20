module DispatchRider
  module Logging
    class BaseFormatter
      def format_error_handler_fail(message, exception)
        raise NotImplementedError
      end

      def format_got_stop(message, reason)
        raise NotImplementedError
      end

      def format_handling(kind, message, exception: nil, duration: nil)
        raise NotImplementedError
      end

      private

      def message_info_arguments(message)
        message.body.dup.tap do |m|
          m.delete('guid')
          m.delete('object_id')
        end
      end

      def format_duration(duration)
        '%.2f' % duration
      end
    end
  end
end
