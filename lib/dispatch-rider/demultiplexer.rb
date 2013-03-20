module DispatchRider
  class Demultiplexer
    attr_reader :queue, :dispatcher

    def initialize(queue, dispatcher)
      @queue = queue
      @dispatcher = dispatcher
    end

    def start
      _log("Starting demultiplexer")
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
      _log("Stopping demultiplexer")
      @continue = false
    end

    def dispatch_message(message)
      _log("Dispatching message : #{message.to_s}")
      dispatcher.dispatch(message)
    end

    private

    def _log(message)
      $stdout.puts message
    end
  end
end
