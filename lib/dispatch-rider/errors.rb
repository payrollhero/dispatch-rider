module DispatchRider
  class DispatchRiderError < StandardError
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
