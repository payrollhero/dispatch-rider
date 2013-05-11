# This is a basic implementation of the Notification service using Amazon SNS.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::AwsSns.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})
module DispatchRider
  module NotificationServices
    class AwsSns < Base
      def notifier_builder
        AWS::SNS
      rescue NameError
        raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
      end

      def channel_registrar_builder
        Registrars::SnsChannel
      end

      def channel(name)
        notifier.topics[self.fetch(name)]
      end
    end
  end
end
