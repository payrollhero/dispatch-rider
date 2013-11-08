require "active_support/core_ext/hash/indifferent_access"
require_relative "publisher/configuration_support"

# This class takes care of the publishing side of the messaging system.
module DispatchRider
  class Publisher
    extend ConfigurationSupport

    attr_reader :service_channel_mapper, :notification_service_registrar, :publishing_destination_registrar, :sns_channel_registrar

    def initialize(configuration = self.class.configuration)
      @notification_service_registrar = DispatchRider::Registrars::NotificationService.new
      @publishing_destination_registrar = DispatchRider::Registrars::PublishingDestination.new
      @service_channel_mapper = ServiceChannelMapper.new(publishing_destination_registrar)

      ConfigurationReader.load_config(configuration, self)
    end

    def register_notification_service(name, options = {})
      notification_service_registrar.register(name, options)
      self
    end

    def register_destination(name, service, channel, options = {})
      register_channel(service, channel, options)
      publishing_destination_registrar.register(name, :service => service, :channel => channel)
      self
    end

    def register_channel(service, name, options = {})
      notification_service = notification_service_registrar.fetch(service)
      notification_service.register(name, options)
      self
    end

    def publish(opts = {})
      options = opts.dup
      service_channel_mapper.map(options.delete(:destinations)).each do |(service, channels)|
        notification_service_registrar.fetch(service).publish(options.merge(:to => channels))
      end
    end

    class ServiceChannelMapper
      attr_reader :destination_registrar

      def initialize(destination_registrar)
        @destination_registrar = destination_registrar
      end

      def map(names)
        services_and_channels_map(publishing_destinations(names))
      end

      private

      def publishing_destinations(names)
        Array(names).map { |name| destination_registrar.fetch(name) }
      end

      def services_and_channels_map(destinations)
        destinations.reduce({}) do |result, destination|
          if result.has_key?(destination.service)
            result[destination.service] << destination.channel
          else
            result[destination.service] = [destination.channel]
          end
          result
        end
      end
    end
  end
end

require_relative "publisher/configuration"
require_relative "publisher/configuration_reader"
