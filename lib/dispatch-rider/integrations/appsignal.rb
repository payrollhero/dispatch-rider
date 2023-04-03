# frozen_string_literal: true

if defined? Appsignal
  Appsignal.logger.info('Loading Dispatch Rider integration')

  module DispatchRider
    module Integrations
      module Appsignal
        def self.wrap_message(job, message)
          ::Appsignal.start

          ::Appsignal.monitor_transaction(
            'perform_job.dispatch-rider',
            class: message.subject,
            method: 'handle',
            attempts: message.receive_count,
            queue: message.queue_name,
            queue_time: (Time.now.to_f - message.sent_at.to_f) * 1000
          ) do
            job.call
          end

          ::Appsignal.stop
        end
      end
    end
  end

  DispatchRider.configure do |config|
    config.around(:dispatch_message) do |job, message|
      DispatchRider::Integrations::Appsignal.wrap_message(job, message)
    end
  end

end
