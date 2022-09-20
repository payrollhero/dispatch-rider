# frozen_string_literal: true

module DispatchRider
  class Publisher::Configuration::Destination
    def initialize(name, attributes={})
      @name = name

      attributes = attributes.with_indifferent_access
      @service = attributes[:service]
      @channel = attributes[:channel]
      @options = attributes[:options]
    end

    attr_reader :name, :service, :channel, :options

    def ==(other)
      self.name == other.name &&
        self.service == other.service &&
        self.channel == other.channel &&
        self.options == other.options
    end
  end
end
