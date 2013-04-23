# Top level namespace of the gem
require "dispatch-rider/version"

require "active_support/hash_with_indifferent_access"
require "active_support/inflector"
require "active_support/json"
require "active_support/core_ext/array/conversions"
require "active_model"

module DispatchRider
end

require "dispatch-rider/errors"
require "dispatch-rider/message"
require "dispatch-rider/registrars"
require "dispatch-rider/notification_services"
require "dispatch-rider/queue_services"
require "dispatch-rider/dispatcher"
require "dispatch-rider/demultiplexer"
require "dispatch-rider/pub_sub"
