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
