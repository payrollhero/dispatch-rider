# frozen_string_literal: true

# The namespace that holds the queue services
module DispatchRider
  module QueueServices
  end
end

require 'ostruct'
require "dispatch-rider/queue_services/base"
require "dispatch-rider/queue_services/simple"
require "dispatch-rider/queue_services/aws_sqs"
require "dispatch-rider/queue_services/file_system"
