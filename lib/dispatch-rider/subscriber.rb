# This class takes care of the subscribing side of the messaging system.
module DispatchRider
  class Subscriber
    attr_reader :queue_service_registrar, :dispatcher, :demultiplexer
    attr_accessor :logger

    def initialize
      @queue_service_registrar = DispatchRider::Registrars::QueueService.new
      @dispatcher = DispatchRider::Dispatcher.new
      @logger = Logger.new(STDERR)
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
      Signal.trap("QUIT") do
        # signal number: 3
        logger.info "Received SIGQUIT, stopping demultiplexer"
        demultiplexer.stop
      end
      Signal.trap("TERM") do
        # signal number: 15
        logger.info "Received SIGTERM, stopping demultiplexer"
        demultiplexer.stop
      end

      # user interuption
      already_interupted = false
      Signal.trap("INT") do
        if already_interupted
          logger.info "Received SIGINT second time, aborting"
          exit(0)
        else
          logger.info "Received SIGINT first time, stopping demultiplexer"
          demultiplexer.stop
        end
        already_interupted = true
      end

      demultiplexer.start
    end
  end
end
