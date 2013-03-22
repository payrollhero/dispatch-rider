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

DispatchRider::Queue.register_service(:array, DispatchRider::QueueServices::RegularQueue)
DispatchRider::Queue.register_service(:aws_sqs, DispatchRider::QueueServices::AwsSqs)
