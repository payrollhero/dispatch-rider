# frozen_string_literal: true

module DispatchRider
  class Publisher::Configuration::Destination
    def initialize(name, attributes = {})
      @name = name

      attributes = attributes.with_indifferent_access
      @service = attributes[:service]
      @channel = attributes[:channel]
      @options = attributes[:options]
    end

    attr_reader :name, :service, :channel, :options

    def ==(other)
      name == other.name &&
        service == other.service &&
        channel == other.channel &&
        options == other.options
    end
  end
end
