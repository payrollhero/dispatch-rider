# frozen_string_literal: true

module DispatchRider
  class Runner
    include Callbacks::Support

    def self.run
      new.process
    end

    def initialize
      callbacks.invoke(:initialize) do
        ready
        set_queue_from_config
      end
    end
    private_class_method :new

    def process
      callbacks.invoke(:process) do
        logger.info "Running..."
        @subscriber.process
      end
    end

    private

    delegate :config, to: :DispatchRider
    delegate :logger, to: :config

    def ready
      logger.info "Creating subscriber..."
      @subscriber = config.subscriber.new

      config.handlers.each do |handler_name|
        logger.info "Registering #{handler_name} handler..."
        @subscriber.register_handler(handler_name)
      end
    end

    def set_queue_from_config
      kind = config.queue_kind
      info = config.queue_info

      logger.info "Setting #{kind} queue @ #{info.to_json} ..."
      @subscriber.register_queue(kind, info)
      @subscriber.setup_demultiplexer(kind, config.error_handler)
    end
  end
end
