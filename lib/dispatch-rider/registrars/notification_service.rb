module DispatchRider
  module Registrars
    class NotificationService < Base
      def value(name, options = {})
        "DispatchRider::NotificationServices::#{name.to_s.camelize}".constantize.new(options)
      end
    end
  end
end
