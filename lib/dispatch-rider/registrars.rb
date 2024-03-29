# frozen_string_literal: true

# The namespace that holds the registrars
module DispatchRider
  module Registrars
  end
end

require "dispatch-rider/registrars/base"
require "dispatch-rider/registrars/notification_service"
require "dispatch-rider/registrars/sns_channel"
require "dispatch-rider/registrars/publishing_destination"
require "dispatch-rider/registrars/file_system_channel"
require "dispatch-rider/registrars/queue_service"
require "dispatch-rider/registrars/handler"
