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
