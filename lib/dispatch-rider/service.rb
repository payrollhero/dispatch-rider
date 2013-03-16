module DispatchRider
  module QueueServices
    module Service

      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks
      end

      module InstanceMethods
        def initialize
          run_callbacks :initialize do
            # nothing to do
          end
        end
      end

    end
  end
end
