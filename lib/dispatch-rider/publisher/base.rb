require 'securerandom'

module DispatchRider
  class Publisher::Base

    class << self

      def subject(subject)
        @subject = subject
      end

      def destinations(destinations)
        @destinations = Array(destinations)
      end

      def default_publisher
        @@default_publisher ||= DispatchRider::Publisher.new
      end

      def publish(*args, &block)
        raise NotImplementedError
      end

    end

    def initialize(publisher = nil)
      @publisher = publisher
    end

    def publish(body)
      raise ArgumentError, 'body should be a hash' unless body.kind_of?(Hash)
      publisher.publish(destinations: destinations, message: { subject: subject, body: body })
    end

    def publisher
      @publisher || self.class.default_publisher
    end

    def destinations
      self.class.instance_variable_get(:@destinations)
    end

    def subject
      self.class.instance_variable_get(:@subject)
    end

  end
end
