module DispatchRider

  # This is the default error handler for dispatch rider.
  # It simply re-raises the exception.
  module DefaultErrorHandler
    def self.call(message, exception)
      raise exception
    end
  end

end
