module DispatchRider
  class Dispatcher
    attr_reader :handlers

    def initialize
      @handlers = {}
    end

    def register(handler)
      handlers[handler.to_sym] = begin
        handler.to_s.camelize.constantize
      rescue NameError
        raise HandlerNotFound.new(handler)
      end
      self
    end

    def unregister(handler)
      handlers.delete(handler.to_sym)
      self
    end

    def fetch(handler)
      begin
        handlers.fetch(handler.to_sym)
      rescue IndexError
        raise HandlerNotRegistered.new(handler)
      end
    end

    def dispatch(message)
      fetch(message.subject).process(message.body)
    end
  end
end
