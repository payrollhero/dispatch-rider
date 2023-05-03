# frozen_string_literal: true

require 'ostruct'

module DispatchRider
  module Registrars
    class PublishingDestination < Base
      def value(_name, options = {})
        ::OpenStruct.new(service: options[:service], channel: options[:channel])
      end
    end
  end
end
