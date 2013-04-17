# This base class provides an interface that we can implement
# to generate a wrapper around a notification service.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::Base.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})
module DispatchRider
  module NotificationServices
    class Base
      attr_reader :notifier, :channel_registrar

      def initialize(channel_registrar)
        @notifier = assign_notifier
        @channel_registrar = channel_registrar
      end

      def assign_notifier
        raise NotImplementedError
      end

      def publish(options)
        channels(options[:to]).each do |channel|
          channel.publish(options[:message])
        end
      end

      def channels(names)
        Array(names).map { |name| channel(name) }
      end

      def channel(name)
        channel_registrar.fetch(name.to_sym)
      end
    end
  end
end
