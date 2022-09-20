# frozen_string_literal: true

# This module tracks which classes inherit from the class that includes
# the module, and provides an accessor to it.

module DispatchRider
  module Handlers
    module InheritanceTracking
      def inherited(subclass)
        subclasses << subclass
        super
      end

      def subclasses
        @subclasses ||= Set.new
      end
    end
  end
end
