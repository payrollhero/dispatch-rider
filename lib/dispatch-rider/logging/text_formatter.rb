module DispatchRider
  module Logging
    class TextFormatter

      def format_error_handler_fail(message, exception)
        "Failed error handling of: #{exception_info_fragment(message, exception)}"
      end

      def format_got_stop(message, reason)
        "Got stop #{reason ? '(' + reason + ') ' : ' ' }while executing: #{message_info_fragment(message)}"
      end

      def format_handling(kind, message, exception = nil)
        case kind
        when :start
          "Starting execution of: #{message_info_fragment(message)}"
        when :success
          "Succeeded execution of: #{message_info_fragment(message)}"
        when :fail
          "Failed execution of: #{exception_info_fragment(message, exception)}"
        when :complete
          "Completed execution of: #{message_info_fragment(message)}"
        end
      end

      private

      def message_info_fragment(message)
        "(#{message.guid}): #{message.subject} : #{message_info_arguments(message).inspect}"
      end

      def message_info_arguments(message)
        message.body.dup.tap { |m|
          m.delete('guid')
        }
      end

      def exception_info_fragment(message, exception)
        "(#{message.object_id}): #{message.subject} with #{exception.class}: #{exception.message}"
      end

    end
  end
end
