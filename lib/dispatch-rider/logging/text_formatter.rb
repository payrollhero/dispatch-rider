# Text Log Formatter
module DispatchRider
  module Logging
    class TextFormatter

      def format(data)
        case data[:phase]
        when :complete
          "Completed execution of: #{message_info_fragment(data)} in #{format_duration(data[:duration])} seconds"
        when :fail
          "Failed execution of: #{exception_info_fragment(data)}"
        when :start
          "Starting execution of: #{message_info_fragment(data)}"
        when :success
          "Succeeded execution of: #{message_info_fragment(data)}"
        when :stop
          "Got stop #{data[:reason] ? '(' + data[:reason] + ')' : '' } while executing: #{message_info_fragment(data)}"
        when :error_handler_fail
          "Failed error handling of: #{exception_info_fragment(data)}"
        else
          raise ArgumentError, "Invalid phase : #{data[:phase].inspect}"
        end
      end

      private

      def message_info_fragment(data)
        "(#{data[:guid]}): #{data[:subject]} : #{message_info_arguments(data[:body]).inspect}"
      end

      def exception_info_fragment(data)
        "(#{data[:guid]}): #{data[:subject]} with #{data[:exception][:class]}: #{data[:exception][:message]}"
      end

      def message_info_arguments(body)
        body.dup.tap do |m|
          m.delete('guid')
          m.delete('object_id')
        end
      end

      def format_duration(duration)
        '%.2f' % [duration]
      end

    end
  end
end
