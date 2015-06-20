require 'json'

module DispatchRider
  module Logging
    class JsonFormatter
      def format_error_handler_fail(message, exception)
        as_json do
          {
            message: "Failed error handling",
          }.merge exception_info_fragment(message, exception)
        end
      end

      def format_got_stop(message, reason)
        as_json do
          {
            message: "Got stop",
            reason: reason,
          }.merge message_info_fragment(message)
        end
      end

      def format_handling(kind, message, exception = nil)
        as_json do
          case kind
          when :start
            { message: "Starting execution" }.merge message_info_fragment(message)
          when :success
            { message: "Succeeded execution" }.merge message_info_fragment(message)
          when :fail
            { message: "Failed execution" }.merge exception_info_fragment(message, exception)
          when :complete
            { message: "Completed execution" }.merge message_info_fragment(message)
          end
        end
      end

      private

      def as_json
        JSON.generate yield
      end

      def message_info_fragment(message)
        {
          guid: message.guid.to_s,
          object_id: message.object_id.to_s,
          subject: message.subject,
          body: message_info_arguments(message),
        }
      end

      def message_info_arguments(message)
        message.body.dup.tap do |m|
          m.delete('guid')
          m.delete('object_id')
        end
      end

      def exception_info_fragment(message, exception)
        exception_details = {
          expection: {
            class: exception.class.to_s,
            message: exception.message,
          }
        }
        message_info_fragment(message).merge exception_details
      end
    end
  end
end
