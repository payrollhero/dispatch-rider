# frozen_string_literal: true
require 'aws-sdk-sns'

# This is a basic implementation of the Notification service using Amazon SNS.
# The expected usage is as follows :
#   notification_service = DispatchRider::NotificationServices::AwsSns.new
#   notification_service.publish(:to => [:foo, :oof], :message => {:subject => "bar", :body => "baz"})
module DispatchRider
  module NotificationServices
    class AwsSns < Base
      def notifier_builder
        Aws::SNS::Client
      end

      def channel_registrar_builder
        Registrars::SnsChannel
      end

      def publish_to_channel(channel, message:)
        Retriable.retriable(tries: 10, on: Aws::Errors::MissingCredentialsError) { super }
      end

      # not really happy with this, but the notification service registrar system is way too rigid to do this cleaner
      # since you only can have one notifier for the whole service, but you need to create a new one for each region
      def channel(name)
        arn = fetch(name)
        # in v1, the Topic object was fetched from API, in v3 it's basically just an arn wrapper
        Aws::SNS::Topic.new(arn)
      end
    end
  end
end
