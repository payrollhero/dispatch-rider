if defined? Appsignal
  Appsignal.logger.info('Loading Dispatch Rider integration')

  module DispatchRider
    module Integrations
      module Appsignal

        def self.wrap_message(job, message)
          begin
            Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)

            ActiveSupport::Notifications.instrument(
              'perform_job.dispatch-rider',
              :class => message.subject,
              :method => 'handle',
              :attempts => message.receive_count,
              :queue => message.queue_name,
              :queue_time => (Time.now.to_f - message.sent_at.to_f) * 1000
            ) do
              job.call
            end
          rescue Exception => exception
            unless Appsignal.is_ignored_exception?(exception)
              Appsignal::Transaction.current.add_exception(exception)
            end
            raise exception
          ensure
            Appsignal::Transaction.current.complete!
          end
        end

      end
    end
  end

  DispatchRider.config do |config|

    config.around(:dispatch_message) do |job, message|
      DispatchRider::Appsignal.wrap_message(job, message)
    end

  end

end
