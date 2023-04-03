# frozen_string_literal: true

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
      names.each { |name| register_handler(name) }
      self
    end

    def setup_demultiplexer(queue_name, error_handler = DispatchRider::DefaultErrorHandler)
      queue = queue_service_registrar.fetch(queue_name)
      @demultiplexer ||= DispatchRider::Demultiplexer.new(queue, dispatcher, error_handler)
      self
    end

    def process
      register_quit_trap
      register_term_trap
      register_int_trap

      demultiplexer.start
    end

    private

    def register_quit_trap
      Signal.trap("QUIT") do
        # signal number: 3
        logger.info "Received SIGQUIT, stopping demultiplexer"
        demultiplexer.stop(reason: "Got SIGQUIT")
      end
    end

    def register_term_trap
      Signal.trap("TERM") do
        # signal number: 15
        logger.info "Received SIGTERM, stopping demultiplexer"
        demultiplexer.stop(reason: "Got SIGTERM")
      end
    end

    def register_int_trap
      @already_interrupted = false
      Signal.trap("INT") do
        if @already_interrupted
          logger.info "Received SIGINT second time, aborting"
          exit(0)
        else
          logger.info "Received SIGINT first time, stopping demultiplexer"
          demultiplexer.stop(reason: "Got SIGINT")
        end
        @already_interrupted = true
      end
    end

    def logger
      DispatchRider.config.logger
    end
  end
end
