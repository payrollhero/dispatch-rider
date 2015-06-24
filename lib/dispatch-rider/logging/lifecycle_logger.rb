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
          logger.error formatter.format log_data
        end

        def log_got_stop(reason, message)
          log_data = translator.translate message, :stop, reason: reason
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
          # 1. fetch log data
          # 2. feed log_data into callback proc
          # 3. in the callback proc, modify log_data with the additional params you wish to add
          # 4. pass #3's modified log data into the formatter
          log_data = translator.translate message, :complete, duration: duration
          logger.info formatter.format log_data
        end

        def translator
          Translator
        end

        def log_fail(message, exception)
          log_data = translator.translate message, :fail, exception: exception
          logger.error formatter.format log_data
        end

        def log_success(message)
          log_data = translator.translate message, :success
          logger.info formatter.format log_data
        end

        def log_start(message)
          log_data = translator.translate message, :start
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
