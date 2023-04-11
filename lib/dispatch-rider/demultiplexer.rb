# frozen_string_literal: true

# The demultiplexer in the reactor pattern is implemented in this class.
# The object needs to be initiated with a queue and a dispatcher.
# Demultiplexer#start defines an event loop which pops items from the queue
# and passes it on to the dispatcher for dispatching to the appropriate message handler.
# The demultiplexer can be stopped by calling the Demultiplexer#stop method.
module DispatchRider
  class Demultiplexer
    attr_reader :queue, :dispatcher, :error_handler

    def initialize(queue, dispatcher, error_handler)
      @queue = queue
      @dispatcher = dispatcher
      @error_handler = error_handler
      @continue = true
      @current_message = nil
    end

    def start
      do_loop do

        sleep 1
        handle_next_queue_item
      rescue => e
        error_handler.call(Message.new(subject: "TopLevelError", body: {}), e)
        throw :done

      end
      self
    end

    def stop(reason: nil)
      @continue = false
      Logging::LifecycleLogger.log_got_stop reason, @current_message if @current_message
    end

    private

    def with_current_message(message)
      @current_message = message
      yield
    ensure
      @current_message = nil
    end

    # This needs to return true/false based on the success of the jobs!
    def dispatch_message(message)
      with_current_message(message) do
        dispatcher.dispatch(message)
      end
    rescue => e
      handle_message_error message, e
      false
    end

    def do_loop
      catch(:done) do
        while keep_going?
          throw :done unless @continue
          yield
        end
      end
    end

    def keep_going?
      true
    end

    def handle_next_queue_item
      queue.pop do |message|
        dispatch_message(message)
      end
    end

    def handle_message_error(message, exception)
      error_handler.call(message, exception)
    rescue => e # the error handler crashed
      Logging::LifecycleLogger.log_error_handler_fail message, e
      raise e
    end

    def logger
      DispatchRider.config.logger
    end
  end
end
