# Top level namespace of the gem
require "dispatch-rider/version"

require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/inflector"
require "active_support/json"
require "active_support/isolated_execution_state"
require "active_support/core_ext/array/conversions"
require "active_model"

require "dispatch-rider/configuration"
require 'retriable'

module DispatchRider
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
    alias_method :config, :configuration

    def clear_configuration!
      @configuration = nil
    end
  end
end

require "dispatch-rider/debug"
require "dispatch-rider/errors"
require "dispatch-rider/error_handlers"
require "dispatch-rider/handlers"
require "dispatch-rider/callbacks"
require "dispatch-rider/message"
require "dispatch-rider/registrars"
require "dispatch-rider/notification_services"
require "dispatch-rider/queue_services"
require "dispatch-rider/dispatcher"
require "dispatch-rider/demultiplexer"
require "dispatch-rider/runner"
require "dispatch-rider/publisher"
require "dispatch-rider/subscriber"
require "dispatch-rider/scheduled_job"
require "dispatch-rider/logging"
