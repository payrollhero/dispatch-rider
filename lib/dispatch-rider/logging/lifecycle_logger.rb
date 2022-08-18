module DispatchRider
  module Logging
    class LifecycleLogger
      class << self
        def log_error_handler_fail(message, exception)
          new(:error_handler_fail, message, exception: exception).log
        end

        def log_got_stop(reason, message)
          new(:stop, message, reason: reason).log
        end

        def wrap_handling(message)
          start_time = Time.now
          log_start(message)
          yield
          log_success(message)
        rescue => exception
          log_fail(message, exception)
          raise exception
        ensure
          log_complete(message, Time.now - start_time)
        end

        private

        def log_complete(message, duration)
          new(:complete, message, duration: duration).log
        end

        def log_fail(message, exception)
          new(:fail, message, exception: exception).log
        end

        def log_success(message)
          new(:success, message).log
        end

        def log_start(message)
          new(:start, message).log
        end
      end

      def initialize(kind, message, options = {})
        @kind = kind
        @message = message
        @options = options
      end

      def log
        logger.send(log_action, formatted_data)
      end

      private

      attr_reader :kind, :message, :options

      def formatter
        DispatchRider.config.log_formatter
      end

      def logger
        DispatchRider.config.logger
      end

      def additional_info_injector
        DispatchRider.config.additional_info_injector
      end

      def translator
        Translator
      end

      def translated_message
        translator.translate(message, kind, options)
      end

      def interjected_message
        additional_info_injector.call(translated_message)
      end

      def formatted_data
        formatter.format(interjected_message)
      end

      def log_action
        case kind
        when :fail, :error_handler_fail then :error
        when :start, :stop, :complete, :success then :info
        end
      end
    end
  end
end
