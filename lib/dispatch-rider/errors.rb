module DispatchRider
  class DispatchRiderError < StandardError
  end

  class HandlerNotFound < DispatchRiderError
    def initialize(name)
      super("The handler #{name.to_s} could not be registered, because such a handler does not exist")
    end
  end

  class HandlerNotRegistered < DispatchRiderError
    def initialize(name)
      super("The handler #{name.to_s} has not been registered")
    end
  end

  class QueueServiceNotFound < DispatchRiderError
    def initialize(name)
      super("The queue service #{name.to_s} could not be registered, because such a service does not exist")
    end
  end

  class QueueServiceNotRegistered < DispatchRiderError
    def initialize(name)
      super("The queue service #{name.to_s} has not been registered")
    end
  end

  class AdapterNotFoundError < DispatchRiderError
    def initialize(lib_name, gem_name)
      super("Constant #{lib_name} wasn't found. Please install the #{gem_name} gem")
    end
  end

  class RecordInvalid < DispatchRiderError
    def initialize(object, error_messages)
      super("#{object.class.name} is not valid because of the following errors : #{error_messages.to_sentence}")
    end
  end
end
