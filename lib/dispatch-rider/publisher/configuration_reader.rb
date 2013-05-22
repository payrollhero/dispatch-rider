module DispatchRider

  class Publisher

    module ConfigurationReader

      class << self
        def parse(configuration_hash, publisher)
          configure_notification_services(configuration_hash, publisher)
          configure_destinations(configuration_hash, publisher)
        end

        private

          def configure_notification_services(configuration_hash, publisher)
            configuration_hash[:notification_services].each do |(service_name, service_options)|
              publisher.register_notification_service(service_name, service_options)
            end if configuration_hash[:notification_services]
          end

          def configure_destinations(configuration_hash, publisher)
            configuration_hash[:destinations].each do |(destination_name, info)|
              publisher.register_destination(destination_name, info[:service], info[:channel], info[:options])
            end if configuration_hash[:destinations]
          end

      end
    end

  end

end
