module DispatchRider
  module Logging
    class LifecycleLogger
      class << self
        def log_error_handler_fail(message, exception)
          logger.error formatter.format_error_handler_fail(message, exception)
        end

        def log_got_stop(reason, message)
          logger.info formatter.format_got_stop(message, reason)
        end

        def wrap_handling(message)
          log_start(message)
          start_time = Time.now
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
          logger.info formatter.format_handling :complete, message, duration: duration
        end

        def log_fail(message, exception)
          logger.error formatter.format_handling :fail, message, exception: exception
        end

        def log_success(message)
          logger.info formatter.format_handling :success, message
        end

        def log_start(message)
          logger.info formatter.format_handling :start, message
        end

        def formatter
          DispatchRider.config.log_formatter
        end

        def logger
          DispatchRider.config.logger
        end
      end
    end
  end
end
