# This class is responsible for dispatching the messages to the appropriate handler.
# The handlers must be registered with the dispatcher.
# Tha handlers need to be modules that implement the process method.
# What handler to dispatch the message to is figured out from the subject of the message.
module DispatchRider
  class Dispatcher
    attr_reader :handlers

    def initialize
      @handlers = {}
    end

    def register(handler)
      handlers[handler.to_sym] = handler.to_s.camelize.constantize
      self
    rescue NameError
      raise HandlerNotFound.new(handler)
    end

    def unregister(handler)
      handlers.delete(handler.to_sym)
      self
    end

    def fetch(handler)
      handlers.fetch(handler.to_sym)
    rescue IndexError
      raise HandlerNotRegistered.new(handler)
    end

    def dispatch(message)
      fetch(message.subject).process(message.body)
    end
  end
end
