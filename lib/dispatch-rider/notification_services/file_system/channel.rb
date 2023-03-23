# frozen_string_literal: true

# this represents a FileSystem queue channel (or basically a folder)

module DispatchRider
  module NotificationServices
    module FileSystem
      class Channel
        def initialize(path)
          @file_system_queue = DispatchRider::QueueServices::FileSystem::Queue.new(path)
        end

        def publish(message)
          @file_system_queue.add(message[:message])
        end
      end
    end
  end
end
