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
    end

    def start
      do_loop do
        begin
          handle_next_queue_item
        rescue => exception
          error_handler.call(Message.new(subject: "TopLevelError", body: {}), exception)
          throw :done
        end
      end
      self
    end

    def stop
      @continue = false
    end

    private

    def dispatch_message(message)
      dispatcher.dispatch(message)
    rescue => exception
      handle_message_error message, exception
      false
    end

    def do_loop
      catch(:done) do
        loop do
          throw :done unless @continue
          yield
        end
      end
    end

    def handle_next_queue_item
      queue.pop do |message|
        begin
          logger.info "Starting execution of: (#{message.object_id}): #{message.subject} : #{message.body.inspect}"
          dispatch_message(message)
        ensure
          logger.info "Completed execution of: (#{message.object_id}): #{message.subject}"
        end
      end
    end

    def handle_message_error(message, exception)
      begin
        logger.error "Failed execution of: (#{message.object_id}): #{message.subject} with #{exception.class}: #{exception.message}"
        error_handler.call(message, exception)
      rescue => exception2
        logger.error "Failed error handling of: (#{message.object_id}): #{message.subject} with #{exception2.class}: #{exception2.message}"
        raise exception2
      end
    end

    def logger
      DispatchRider.config.logger
    end

  end
end
