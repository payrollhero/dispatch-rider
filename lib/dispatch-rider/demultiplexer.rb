# The demultiplexer in the reactor pattern is implemented in this class.
# The object needs to be initiated with a queue and a dispatcher.
# Demultiplexer#start defines an event loop which pops items from the queue
# and passes it on to the dispatcher for dispatching to the appropriate message handler.
# The demultiplexer can be stopped by calling the Demultiplexer#stop method.
module DispatchRider
  class Demultiplexer
    attr_reader :queue, :dispatcher

    def initialize(queue, dispatcher)
      @queue = queue
      @dispatcher = dispatcher
    end

    def start
      @continue = true
      loop do
        break unless @continue
        queue.pop do |message|
          dispatch_message(message)
        end
      end
      self
    end

    def stop
      @continue = false
    end

    def dispatch_message(message)
      dispatcher.dispatch(message)
    end
  end
end
