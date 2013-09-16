module DispatchRider
  class Runner

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
        puts "Running..."
        @subscriber.process
      end
    end

    private

    def config
      DispatchRider.config
    end

    def callbacks
      @callbacks ||= Callbacks::Access.new(config.callbacks)
    end

    def ready
      puts "Creating subscriber..."
      @subscriber = config.subscriber.new

      config.handlers.each do |handler_name|
        puts "Registering #{handler_name} handler..."
        @subscriber.register_handler(handler_name)
      end
    end

    def set_queue_from_config
      kind = config.queue_kind
      info = config.queue_info

      puts "Setting #{kind} queue @ #{info.to_json} ..."
      @subscriber.register_queue(kind, info)
      @subscriber.setup_demultiplexer(kind, config.error_handler)
    end

  end
end
