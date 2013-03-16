module DispatchRider
  class Message
    attr_accessor :subject, :body

    def initialize(attrs)
      @subject = attrs.fetch(:subject)
      @body = attrs.fetch(:body)
    end
  end
end
