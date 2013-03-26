# This file contains all the error classes for this gem.
module DispatchRider
  # The base error class of the gem
  class DispatchRiderError < StandardError
  end

  # This error is raised when a handler one is trying to register with the dispatcher is not found
  class HandlerNotFound < DispatchRiderError
    def initialize(name)
      super("The handler #{name.to_s} could not be registered, because such a handler does not exist")
    end
  end

  # This error is raised when you try to call a handler that has not been registered with the dispatcher
  class HandlerNotRegistered < DispatchRiderError
    def initialize(name)
      super("The handler #{name.to_s} has not been registered")
    end
  end

  # This error is raised when you try to register a queue service that is not present
  class QueueServiceNotFound < DispatchRiderError
    def initialize(name)
      super("The queue service #{name.to_s} could not be registered, because such a service does not exist")
    end
  end

  # This error is raised when you try to fetch a queue service that is not registered
  class QueueServiceNotRegistered < DispatchRiderError
    def initialize(name)
      super("The queue service #{name.to_s} has not been registered")
    end
  end

  # This error is raised when a queue service depends on an external library, but that is not present
  class AdapterNotFoundError < DispatchRiderError
    def initialize(lib_name, gem_name)
      super("Constant #{lib_name} wasn't found. Please install the #{gem_name} gem")
    end
  end

  # This error is raised when validation fails on an object
  class RecordInvalid < DispatchRiderError
    def initialize(object, error_messages)
      super("#{object.class.name} is not valid because of the following errors : #{error_messages.to_sentence}")
    end
  end
end
