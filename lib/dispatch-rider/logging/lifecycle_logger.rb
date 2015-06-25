module DispatchRider
  module Logging

    # Jobs:
    #  - accept 3 public interfaces
    #  - translate them to a universal logging hash
    #  - apply additional logging data
    #  - log it
    class LifecycleLogger
      class << self
        def log_error_handler_fail(message, exception)
          log_data = translator.translate message, :error_handler_fail, exception: exception

          additional_info_interjector.call(log_data)
          logger.error formatter.format log_data
        end

        def log_got_stop(reason, message)
          log_data = translator.translate message, :stop, reason: reason
          additional_info_interjector.call(log_data)
          logger.info formatter.format log_data
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
          log_data = translator.translate message, :complete, duration: duration
          additional_info_interjector.call(log_data)
          logger.info formatter.format log_data
        end

        def translator
          Translator
        end

        def log_fail(message, exception)
          log_data = translator.translate message, :fail, exception: exception
          additional_info_interjector.call(log_data)
          logger.error formatter.format log_data
        end

        def log_success(message)
          log_data = translator.translate message, :success
          additional_info_interjector.call(log_data)
          logger.info formatter.format log_data
        end

        def log_start(message)
          log_data = translator.translate message, :start
          additional_info_interjector.call(log_data)
          logger.info formatter.format log_data
        end

        def formatter
          DispatchRider.config.log_formatter
        end

        def logger
          DispatchRider.config.logger
        end

        def additional_info_interjector
          DispatchRider.config.additional_info_interjector
        end
      end
    end
  end
end
