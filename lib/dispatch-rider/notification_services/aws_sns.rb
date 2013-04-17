module DispatchRider
  module NotificationServices
    class AwsSns < Base
      def assign_notifier
        @notifier = AWS::SNS.method(:new)
      rescue NameError
        raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
      end
    end
  end
end
