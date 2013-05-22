module DispatchRider

  class Publisher

    module ConfigurationReader

      class << self
        def parse(configuration_hash, publisher)
          configure_notification_services(configuration_hash[:notification_services], publisher) if configuration_hash[:notification_services]
          configure_destinations(configuration_hash[:destinations], publisher) if configuration_hash[:destinations]
        end

        private

          def configure_notification_services(configuration_hash, publisher)
            configuration_hash.each do |(service_name, service_options)|
              publisher.register_notification_service(service_name, service_options)
            end
          end

          def configure_destinations(configuration_hash, publisher)
            configuration_hash.each do |(destination_name, info)|
              publisher.register_destination(destination_name, info[:service], info[:channel], info[:options])
            end
          end

      end
    end

  end

end
