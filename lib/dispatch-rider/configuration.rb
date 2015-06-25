module DispatchRider
  class Configuration
    attr_accessor(
      :handler_path,
      :error_handler,
      :queue_info,
      :queue_kind,
      :subscriber,
      :logger,
      :log_formatter,
      :debug,
      :additional_info_interjector
    )
    attr_reader :callbacks

    def initialize
      @handler_path = Dir.getwd + "/app/handlers"
      @error_handler = DispatchRider::DefaultErrorHandler
      @queue_kind = :file_system
      @queue_info = { path: "tmp/dispatch-rider-queue" }
      @callbacks = Callbacks::Storage.new
      @subscriber = DispatchRider::Subscriber
      @log_formatter = DispatchRider::Logging::TextFormatter.new
      @additional_info_interjector = -> (_data) { }
      @logger = Logger.new(STDERR)
      @debug = false

      @callbacks.around(:dispatch_message) do |job, message|
        Logging::LifecycleLogger.wrap_handling(message) do
          job.call
        end
      end
    end

    delegate :before, :after, :around, :to => :callbacks

    def default_retry_timeout=(val)
      DispatchRider::Handlers::Base.set_default_retry(val)
    end

    def handlers
      @handlers ||= begin
        load_handler_files
        DispatchRider::Handlers::Base.subclasses.map { |klass| klass.name.underscore.to_sym }
      end
    end

    private

    def load_handler_files
      Dir["#{@handler_path}/**/*.rb"].each do |filename|
        require filename.gsub(/\.rb$/, '')
      end
    end
  end
end
