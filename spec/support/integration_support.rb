module IntegrationSupport
  def setup_publisher
    publisher = DispatchRider::Publisher.new
    publisher.register_notification_service :file_system
    publisher.register_destination :dst, :file_system, :dst_channel, path: 'tmp/test_queue'
    publisher
  end

  def purge_test_queue
    Dir['tmp/test_queue/*'].each { |fn| File.unlink(fn) }
  end

  def setup_subscriber
    subscriber = DispatchRider.config.subscriber.new
    subscriber.register_queue(:file_system, path: 'tmp/test_queue')
    subscriber.register_handler(:sample_handler)
    subscriber.register_handler(:crashing_handler)
    subscriber
  end

  def work_off_jobs(subscriber, fail_on_error: true)
    subscriber.setup_demultiplexer(:file_system, ->(_message, error) { raise error if fail_on_error })

    class << subscriber.demultiplexer
      def keep_going?
        !queue.empty?
      end
    end

    subscriber.demultiplexer.start
  end
end
