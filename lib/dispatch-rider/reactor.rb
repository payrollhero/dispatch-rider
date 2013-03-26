# This is the external interface to the gem that is accessible to the clients
# The clients have to initiate a queue, setup the publisher, dispatcher and demultiplexer.
# They need to register their handlers with the dispatcher through this interface as well.
# When all is setup, the clients can publish through the publisher and subscribe by starting the demultiplexer.
module DispatchRider
  class Reactor
    attr_reader :queue_service_registrar, :dispatcher, :demultiplexer, :publisher

    def initialize
      @queue_service_registrar = QueueServiceRegistrar.new
    end

    def register_queue(name, options = {})
      queue_service_registrar.register(name, options)
      self
    end

    def setup_publisher(queue_name)
      queue = queue_service_registrar.fetch(queue_name)
      @publisher ||= Publisher.new(queue)
      self
    end

    def register_handler(name)
      @dispatcher ||= Dispatcher.new
      dispatcher.register(name)
      self
    end

    def register_handlers(*names)
      names.each {|name| register_handler(name)}
      self
    end

    def setup_demultiplexer(queue_name)
      queue = queue_service_registrar.fetch(queue_name)
      @demultiplexer ||= Demultiplexer.new(queue, dispatcher)
      self
    end

    def process
      interuption_count = 0
      Signal.trap("INT") do
        interuption_count += 1
        interuption_count < 2 ? demultiplexer.stop : exit(0)
      end
      demultiplexer.start
    end
  end
end
