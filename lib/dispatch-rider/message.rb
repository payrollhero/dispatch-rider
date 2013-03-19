module DispatchRider
  class Message
    attr_accessor :subject, :body

    def initialize(options)
      attrs = options.symbolize_keys
      @subject = attrs.fetch(:subject)
      @body = attrs.fetch(:body)
    end
  end
end
