module DispatchRider
  module Callbacks
    # Adds callback support to an object.
    module Support
      private

      def callbacks
        @callbacks ||= Callbacks::Access.new DispatchRider.config.callbacks
      end
    end
  end
end
