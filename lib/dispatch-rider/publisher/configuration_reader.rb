module DispatchRider
  class Publisher
    module ConfigurationReader

      class << self
        def load_config(configuration, publisher)
          configure_notification_services(configuration.notification_services, publisher)
          configure_destinations(configuration.destinations, publisher)
        end

        private

        def configure_notification_services(notification_services, publisher)
          notification_services.each do |service|
            publisher.register_notification_service(service.name, service.options)
          end
        end

        def configure_destinations(destinations, publisher)
          destinations.each do |destination|
            publisher.register_destination(destination.name, destination.service, destination.channel, destination.options)
          end
        end

      end

    end
  end
end
