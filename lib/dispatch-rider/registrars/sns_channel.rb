module DispatchRider
  module Registrars
    class SnsChannel < Base
      def value(name, options = {})
        name.to_s
      end
    end
  end
end
