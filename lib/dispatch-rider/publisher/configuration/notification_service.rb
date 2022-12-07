# frozen_string_literal: true

module DispatchRider
  module Publisher
    module Configuration
      class NotificationService
        def initialize(name, options)
          @name = name
          @options = options
        end

        attr_reader :name, :options

        def ==(other)
          name == other.name &&
            options == other.options
        end
      end
    end
  end
end
