# This queue service is based on AWS SNS.
# To make this queue service work, one would need the aws-sdk gem to be installed.
# AwsSns is only half of a queue: the end where items are being pushed into.
# The other end of this queue could be implemented using AWS::SQS.
# Other possible endpoint (not yet implemented by DispatchRider) would be:
#   * HTTP
#   * HTTPS
#   * eMail
#   * eMailJson
#   * SMS

module DispatchRider
  module QueueServices
    class AwsSns < Base

      def assign_storage(attrs)
        begin
          self.class.get_queue_for(attrs.fetch(:name))
        rescue IndexError
          raise RecordInvalid.new(self, ["Name can not be blank"])
        end
      end

      def insert(item)
        queue.publish(item)
      end

      def raw_head
        raise NotImplementedError, "Pulling messages from #{self.class.name} is not supported. Please pull messages from AWS::SNS' endpoint (HTTP, HTTPS, SQS, SMS or eMail)."
      end

      def construct_message_from(item)
        raise NotImplementedError, "Constructing messages from #{self.class.name} is not supported."
      end

      def delete(item)
        raise NotImplementedError, "Deleting messages from #{self.class.name} is not supported."
      end

      def size
        raise NotImplementedError, "Counting messages from #{self.class.name} is not supported."
      end

      private

      def self.sns_constructor
        begin
          AWS::SNS.method(:new)
        rescue NameError
          raise AdapterNotFoundError.new(self.class.name, 'aws-sdk')
        end
      end

      def self.get_queue_for(amazon_resource_name)
        sns_constructor.call.topics[amazon_resource_name]
      end

    end
  end
end
