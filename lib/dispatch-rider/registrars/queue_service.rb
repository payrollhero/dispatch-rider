module DispatchRider
  module Registrars
    class QueueService < Base
      def value(name, options = {})
        "DispatchRider::QueueServices::#{name.to_s.camelize}".constantize.new(options)
      end
    end
  end
end
