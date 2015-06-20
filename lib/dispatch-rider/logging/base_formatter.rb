module DispatchRider
  module Logging
    class BaseFormatter
      def format_error_handler_fail(*)
        raise NotImplementedError
      end

      def format_got_stop(*)
        raise NotImplementedError
      end

      def format_handling(*)
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
