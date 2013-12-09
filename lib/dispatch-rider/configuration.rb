module DispatchRider
  class Configuration
    attr_accessor :handler_path, :error_handler, :queue_info, :queue_kind, :subscriber, :logger
    attr_reader :callbacks

    def initialize
      @handler_path = Dir.getwd + "/app/handlers"
      @error_handler = DispatchRider::DefaultErrorHandler
      @queue_kind = :file_system
      @queue_info = { path: "tmp/dispatch-rider-queue" }
      @callbacks = Callbacks::Storage.new
      @subscriber = DispatchRider::Subscriber
      @logger = Logger.new(STDERR)
    end

    delegate :before, :after, :around, :to => :callbacks

    def handlers
      @handlers ||= begin
                      load_handler_files
                      DispatchRider::Handlers::Base.subclasses.map{ |klass| klass.name.underscore.to_sym }
                    end
    end

    private

    def load_handler_files
      Dir["#{@handler_path}/*.rb"].each do |filename|
        require filename.gsub(/\.rb$/, '')
      end
    end
  end
end
