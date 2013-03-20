module DispatchRider
  module Dispatcher
    @handlers = {}

    class << self
      def register(handler)
        @handlers[handler.to_sym] = handler.to_s.camelize.constantize
      end

      def unregister(handler)
        @handlers.delete(handler.to_sym)
      end

      def dispatch(message)
        handler = @handlers[message.subject.to_sym]
        handler && handler.process(message.body)
      end
    end
  end
end
