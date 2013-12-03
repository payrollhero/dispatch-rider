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
      error_handler.call(message, exception)
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
        dispatch_message(message)
      end
    end

  end
end
