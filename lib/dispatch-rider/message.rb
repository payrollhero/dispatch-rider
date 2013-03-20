module DispatchRider
  class Message
    include ActiveModel::Validations

    attr_accessor :subject, :body

    validates :subject, :presence => true
    validates :body, :presence => true

    def initialize(options)
      attrs = options.symbolize_keys
      @subject = attrs[:subject]
      @body = attrs[:body]
      raise RecordInvalid.new(self, errors.full_messages) unless valid?
    end

    def attributes
      {:subject => subject, :body => body}
    end

    def to_json
      attributes.to_json
    end

    def ==(other)
      attributes == other.attributes
    end

    def to_s
      "The body of the message \"#{subject.to_s}\" is #{body.inspect}"
    end
  end
end
