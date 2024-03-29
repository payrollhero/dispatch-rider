# frozen_string_literal: true

# This is the registrar for the Aws SNS channels.
module DispatchRider
  module Registrars
    class SnsChannel < Base
      def value(_name, options = {})
        "arn:aws:sns:#{options[:region]}:#{options[:account]}:#{options[:topic]}"
      end
    end
  end
end
