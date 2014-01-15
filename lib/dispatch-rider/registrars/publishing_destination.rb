require 'ostruct'

module DispatchRider
  module Registrars
    class PublishingDestination < Base
      def value(name, options = {})
        ::OpenStruct.new(:service => options[:service], :channel => options[:channel])
      end
    end
  end
end
