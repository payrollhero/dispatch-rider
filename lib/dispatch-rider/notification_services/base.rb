# This base class provides an interface that we can implement
# to generate a wrapper around a notification service.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::Base.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})
module DispatchRider
  module NotificationServices
    class Base
      extend Forwardable

      attr_reader :notifier, :channel_registrar

      def_delegators :channel_registrar, :register, :fetch, :unregister

      def initialize(options)
        @notifier = assign_notifier
        @channel_registrar = assign_channel_registrar
      end

      def assign_notifier
        raise NotImplementedError
      end

      def assign_channel_registrar
        raise NotImplementedError
      end

      def publish(options)
        channels(options[:to]).each do |channel|
          channel.publish(message(options[:message]))
        end
      end

      def channels(names)
        Array(names).map { |name| channel(name) }
      end

      def channel(name)
        raise NotImplementedError
      end

      private

      def message(attrs)
        DispatchRider::Message.new(attrs).to_json
      end
    end
  end
end
