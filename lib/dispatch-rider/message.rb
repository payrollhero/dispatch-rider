# This class represents a message. All other objects dela with passing around instances of this class.
# A message must have a subject and a body. The subject represents the handlers name and the body represents
# the payload of the process method in the handler.
# When messages are stored in the queues, they are serialized.
module DispatchRider
  class Message
    include ActiveModel::Validations

    attr_accessor :subject, :body

    validates :subject, :presence => true

    def initialize(options)
      attrs = options.symbolize_keys
      @subject = attrs[:subject]
      @body = attrs[:body] || {}
      raise RecordInvalid.new(self, errors.full_messages) unless valid?
    end

    def attributes
      {:subject => subject, :body => body}
    end

    def to_json
      attributes.to_json
    end

    def ==(other)
      return false unless other.respond_to? :attributes
      attributes == other.attributes
    end
  end
end
