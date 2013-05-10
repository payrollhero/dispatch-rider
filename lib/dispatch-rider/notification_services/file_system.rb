# this is a basic notification service which uses a filesystem folder to handle notifications

module DispatchRider
  module NotificationServices
    class FileSystem < Base
      def notifier_builder
        Notifier
      end

      def channel_registrar_builder
        DispatchRider::Registrars::FileSystemChannel
      end

      def channel(name)
        notifier.channel(self.fetch(name))
      end
    end
  end
end

require 'dispatch-rider/notification_services/file_system/channel'
require 'dispatch-rider/notification_services/file_system/notifier'
