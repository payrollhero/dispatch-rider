# frozen_string_literal: true

# This is the registrar for the handlers.
module DispatchRider
  module Registrars
    class Handler < Base
      def value(name, _options = {})
        name.to_s.camelize.constantize
      end
    end
  end
end
