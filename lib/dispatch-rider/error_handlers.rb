module DispatchRider

  # This is the default error handler for dispatch rider.
  # It simply re-raises the exception.
  module DefaultErrorHandler
    def self.call(message, exception)
      raise exception
    end
  end

  # This error handler integrates with airbrake.io, i
  # sending the mesage and environment details.
  module AirbrakeErrorHandler
    def self.call(message, exception)
      Airbrake.notify(exception, controller: "DispatchRider", action: message.subject, parameters: message.attributes, cgi_data: ENV.to_hash)
    end
  end
end
