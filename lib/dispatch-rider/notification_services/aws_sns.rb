module DispatchRider
  module NotificationServices
    class AwsSns < Base
      def assign_notifier
        @notifier = AWS::SNS.method(:new)
      rescue NameError
        raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
      end

      def assign_channel_registrar
        Registrars::SnsChannel.new
      end

      def channel(name)
        notifier.call.topics[self.fetch(name)]
      end
    end
  end
end
