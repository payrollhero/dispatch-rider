# frozen_string_literal: true

# The namespace that holds the notification services services
module DispatchRider
  module NotificationServices
  end
end

require "dispatch-rider/notification_services/base"
require "dispatch-rider/notification_services/aws_sns"
require "dispatch-rider/notification_services/file_system"
