# frozen_string_literal: true

require 'securerandom'

module DispatchRider
  # Main template for a dispatch rider publisher.
  class Publisher::Base
    class << self
      # @param [Symbol] subject
      def subject(subject)
        @subject = subject
      end

      # @param [Array<Symbol>, Symbol] destinations
      def destinations(destinations)
        @destinations = Array(destinations)
      end

      # @return [DispatchRider::Publisher]
      def default_publisher
        @@default_publisher ||= DispatchRider::Publisher.new
      end

      def publish(*args, &block)
        raise NotImplementedError, "subclass of DispatchRider::Publisher::Base must implement .publish"
      end
    end

    def initialize(publisher = nil)
      @publisher = publisher
    end

    # @param [Hash] body
    def publish(body)
      validate_body(body)
      publisher.publish(destinations: destinations, message: { subject: subject, body: body })
    end

    # @param [Hash] body
    # @param [Time] at
    def publish_later(body, at:)
      validate_body(body)
      DispatchRider::ScheduledJob.create! scheduled_at: at,
                                          destinations: destinations,
                                          message: { subject: subject, body: body }
    end

    private

    def publisher
      @publisher || self.class.default_publisher
    end

    def destinations
      self.class.instance_variable_get(:@destinations)
    end

    def subject
      self.class.instance_variable_get(:@subject)
    end

    def validate_body(body)
      raise ArgumentError, 'body should be a hash' unless body.is_a?(Hash)
    end
  end
end
