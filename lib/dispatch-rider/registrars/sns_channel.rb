# This is the registrar for the Aws SNS channels.
module DispatchRider
  module Registrars
    class SnsChannel < Base
      def value(name, options = {})
        "arn:aws:sns:#{options[:region]}:#{options[:account]}:#{options[:topic]}"
      end
    end
  end
end
