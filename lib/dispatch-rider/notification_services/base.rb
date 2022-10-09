# frozen_string_literal: true

# This base class provides an interface that we can implement
# to generate a wrapper around a notification service.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::Base.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})

require 'forwardable'

module DispatchRider
  module NotificationServices
    class Base
      extend Forwardable

      attr_reader :notifier, :channel_registrar

      def_delegators :channel_registrar, :register, :fetch, :unregister

      def initialize(options = {})
        @notifier = notifier_builder.new(options)
        @channel_registrar = channel_registrar_builder.new
      end

      def notifier_builder
        raise NotImplementedError
      end

      def channel_registrar_builder
        raise NotImplementedError
      end

      def publish(to:, message:)
        channels(to).each { |channel| publish_to_channel channel, message: message }
      end

      def channels(names)
        Array(names).map { |name| channel(name) }
      end

      def channel(name)
        raise NotImplementedError
      end

      def publish_to_channel(channel, message:)
        channel.publish(message: serialize(message))
      end

      private

      def serialize(item)
        item.to_json
      end
    end
  end
end
