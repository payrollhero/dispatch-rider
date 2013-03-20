module DispatchRider
  class QueueServiceRegistrar
    attr_reader :queue_services

    def initialize
      @queue_services = {}
    end

    def register(service, options = {})
      queue_services[service.to_sym] = begin
        "DispatchRider::QueueServices::#{service.to_s.camelize}".constantize.new(options)
      rescue NameError
        raise QueueServiceNotFound.new(service)
      end
      self
    end

    def unregister(service)
      queue_services.delete(service.to_sym)
      self
    end

    def fetch(service)
      begin
        queue_services.fetch(service.to_sym)
      rescue IndexError
        raise QueueServiceNotRegistered.new(service)
      end
    end
  end
end
