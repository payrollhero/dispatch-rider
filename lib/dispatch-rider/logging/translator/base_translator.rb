module DispatchRider
  module Logging
    class Translator

      class BaseTranslator
        def initialize(message, **_)
          @message = message
        end

        private

        def message_info_fragment(message)
          {
            guid: message.guid.to_s,
            subject: message.subject,
            body: message_info_arguments(message),
          }
        end

        def message_info_arguments(message)
          message.body.dup.tap do |m|
            m.delete('guid')
            m.delete('object_id')
          end
        end

        def exception_info_fragment(message, exception)
          exception_details = {
            exception: {
              class: exception.class.to_s,
              message: exception.message,
            }
          }
          message_info_fragment(message).merge exception_details
        end
      end

    end
  end
end
