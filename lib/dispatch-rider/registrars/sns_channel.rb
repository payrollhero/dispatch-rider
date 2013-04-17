module DispatchRider
  module Registrars
    class SnsChannel < Base
      def value(name, options = {})
        options[:notifier].call.topics[name]
      end
    end
  end
end
