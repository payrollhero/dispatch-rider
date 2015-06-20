module DispatchRider
  module Logging
    class BaseFormatter
      def format_error_handler_fail(_message, _exception)
        raise NotImplementedError
      end

      def format_got_stop(_message, _reason)
        raise NotImplementedError
      end

      def format_handling(_kind, _message, _exception: nil, _duration: nil)
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
        format '%.2f', duration
      end
    end
  end
end
