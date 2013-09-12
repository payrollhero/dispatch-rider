require 'dispatch-rider/handlers/named_process'

module DispatchRider
  module Handlers
    class Base
      include NamedProcess

      def do_process(options)
        with_named_process(self.class.name) do
          process(options)
        end
      end

      def process(options)
        raise NotImplementedError, "Method 'process' not overridden in subclass!"
      end
    end
  end
end
