# Text Log Formatter
module DispatchRider
  module Logging
    class TextFormatter < BaseFormatter
      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [Exception] exception
      # @return [String] log item
      def format_error_handler_fail(message, exception)
        "Failed error handling of: #{exception_info_fragment(message, exception)}"
      end

      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [String] reason
      # @return [String] log item
      def format_got_stop(message, reason)
        "Got stop #{reason ? '(' + reason + ') ' : ' ' }while executing: #{message_info_fragment(message)}"
      end

      # @param [Symbol] kind of log action. one of: :start, :success, :fail, :complete
      # @param [DispatchRider::QueueServices::ReceivedMessage] message
      # @param [Exception] exception
      # @param [Float] Job execution duration
      # @return [String] log item
      def format_handling(kind, message, exception: nil, duration: nil)
        case kind
        when :start
          "Starting execution of: #{message_info_fragment(message)}"
        when :success
          "Succeeded execution of: #{message_info_fragment(message)}"
        when :fail
          "Failed execution of: #{exception_info_fragment(message, exception)}"
        when :complete
          "Completed execution of: #{message_info_fragment(message)} in #{format_duration(duration)} seconds"
        end
      end

      private

      def message_info_fragment(message)
        "(#{message.guid}): #{message.subject} : #{message_info_arguments(message).inspect}"
      end

      def exception_info_fragment(message, exception)
        "(#{message.guid}): #{message.subject} with #{exception.class}: #{exception.message}"
      end
    end
  end
end
