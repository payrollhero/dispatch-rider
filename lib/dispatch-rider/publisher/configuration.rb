# frozen_string_literal: true

module DispatchRider
  module Publisher
    class Configuration
      def initialize(configuration_hash = {})
        @notification_services = []
        @destinations = []
        parse(configuration_hash)
      end

      def notification_services
        @notification_services
      end

      def destinations
        @destinations
      end

      def parse(configuration_hash)
        clear

        configuration_hash = configuration_hash.with_indifferent_access
        configure_notification_services(configuration_hash[:notification_services] || {})
        configure_destinations(configuration_hash[:destinations] || {})
      end

      def clear
        @notification_services.clear
        @destinations.clear
      end

      private

      def configure_notification_services(notification_services_hash)
        notification_services_hash.each do |name, options|
          @notification_services << NotificationService.new(name, options)
        end
      end

      def configure_destinations(destinations_hash)
        destinations_hash.each do |name, options|
          @destinations << Destination.new(name, options)
        end
      end
    end
  end
end

require_relative "configuration/destination"
require_relative "configuration/notification_service"
