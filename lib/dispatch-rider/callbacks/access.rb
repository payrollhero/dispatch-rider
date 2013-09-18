module DispatchRider
  module Callbacks
    class Access
      attr_reader :callbacks

      def initialize(callbacks)
        @callbacks = callbacks
      end

      def invoke(event, *args)
        begin
          invoke_callbacks :before, event, *args
          yield
        ensure
          invoke_callbacks :after, event, *args
        end
      end

      private

      def invoke_callbacks(modifier, event, *args)
        callbacks.for(modifier, event).each do |callback|
          callback.call(*args)
        end
      end

    end
  end
end
