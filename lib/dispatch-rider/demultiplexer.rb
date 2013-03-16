module DispatchRider
  class Demultiplexer

    def initialize(queue)
      @queue = queue
    end

    def start
      @continue = true

      loop do
        break unless @continue

        @queue.pop do |message|
          dispatch_message(message)
        end
      end

      self
    end

    def stop
      @continue = false
    end

    def dispatch_message(message)
      Dispatcher.dispatch(message)
    end

  end
end
