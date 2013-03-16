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

        # if this dispatcher don't know which handler to invoke
        # then ignore it and let others try to dispatch it
        handler.process(message.body) if handler
      end
    end
  end
end
