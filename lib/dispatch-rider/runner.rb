module DispatchRider
  class Runner
    attr_reader :queue_service_registrar, :dispatcher, :demultiplexer, :publisher

    def initialize(options = {})
      @queue_service_registrar = QueueServiceRegistrar.new
      @dispatcher = Dispatcher.new
    end

    def register_queue(name, options)
      queue_service_registrar.register(name, options)
    end

    def register_handler(name)
      dispatcher.register(name)
    end

    def prepare(queue_name)
      queue = queue_service_registrar.fetch(queue_name)
      @demultiplexer = Demultiplexer.new(queue, dispatcher)
      @publisher = Publisher.new(queue)
    end

    def run
      interuption_count = 0
      Signal.trap("INT") do
        interuption_count += 1
        interuption_count < 2 ? demultiplexer.stop : exit(0)
      end
      demultiplexer.start
    end
  end
end
