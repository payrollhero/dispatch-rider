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

      private

      def generate_new_message_id
        if DispatchRider.config.debug
          DispatchRider::Debug::PUBLISHER_MESSAGE_GUID
        else
          SecureRandom.uuid
        end
      end

    end

    def initialize(publisher = nil)
      @publisher = publisher
    end

    def publish(body)
      raise ArgumentError, 'body should be a hash' unless body.kind_of?(Hash)
      body = body.merge({
        'guid' => generate_new_message_id,
      })
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

    private

    def generate_new_message_id
      self.class.send(:generate_new_message_id)
    end

  end
end
