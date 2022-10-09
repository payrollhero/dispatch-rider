# frozen_string_literal: true

# This file contains all the error classes for this gem.
module DispatchRider
  # The base error class of the gem
  class DispatchRiderError < StandardError
  end

  # The error class for objects not being found
  class NotFound < DispatchRiderError
    def initialize(name)
      super("#{name.to_s} could not be found")
    end
  end

  # The error class for keys not registered in a registrar
  class NotRegistered < DispatchRiderError
    def initialize(name)
      super("#{name.to_s} has not been registered")
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
