# frozen_string_literal: true

# This is abstraction around a notifier service for FileSystem based queue services

module DispatchRider
  module NotificationServices
    class FileSystem::Notifier
      def initialize(options)
        # nothing to do here
      end

      def channel(path)
        FileSystem::Channel.new(path)
      end
    end
  end
end
