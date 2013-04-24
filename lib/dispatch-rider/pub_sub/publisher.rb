# This class takes care of the publishing side of the messaging system.
module DispatchRider
  module PubSub
    class Publisher
      attr_reader :notification_service_registrar, :sns_channel_registrar

      def initialize
        @notification_service_registrar = DispatchRider::Registrars::NotificationService.new
      end

      def register_notification_service(name, options = {})
        notification_service_registrar.register(name, options)
        self
      end

      def register_channel(notification_service_name, name, options = {})
        notification_service = notification_service_registrar.fetch(notification_service_name)
        notification_service.register(name, options)
        self
      end

      def publish(options = {})
        notification_service = notification_service_registrar.fetch(options[:service])
        notification_service.publish(options)
      end
    end
  end
end
