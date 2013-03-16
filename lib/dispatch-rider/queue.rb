module DispatchRider
  module Queue
    class << self
      def register_service(name, klass)
        @registered_services ||= {}
        @registered_services[name.to_sym] = klass
      end

      def build(options)
        options.symbolize_keys!
        queue_service = options.delete(:queue_service)
        queue_service = queue_service.to_sym if queue_service
        if @registered_services[queue_service]
          @registered_services[queue_service].new(options)
        else
          raise ArgumentError, "don't know how to handle queue_service: #{queue_service.inspect}: #{options.inspect}"
        end
      end
    end
  end
end

require "dispatch-rider/queue_services/array_queue"
require "dispatch-rider/queue_services/aws_sqs"

DispatchRider::Queue.register_service(:array, DispatchRider::QueueServices::ArrayQueue)
DispatchRider::Queue.register_service(:aws_sqs, DispatchRider::QueueServices::AwsSqs)
