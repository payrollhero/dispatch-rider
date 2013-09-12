# This class takes care of the subscribing side of the messaging system.
module DispatchRider
  class Subscriber
    attr_reader :queue_service_registrar, :dispatcher, :demultiplexer

    def initialize
      @queue_service_registrar = DispatchRider::Registrars::QueueService.new
      @dispatcher = DispatchRider::Dispatcher.new
    end

    def register_queue(name, options = {})
      queue_service_registrar.register(name, options)
      self
    end

    def register_handler(name)
      dispatcher.register(name)
      self
    end

    def register_handlers(*names)
      names.each {|name| register_handler(name)}
      self
    end

    def setup_demultiplexer(queue_name, error_handler = DispatchRider::DefaultErrorHandler)
      queue = queue_service_registrar.fetch(queue_name)
      @demultiplexer ||= DispatchRider::Demultiplexer.new(queue, dispatcher, error_handler)
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
