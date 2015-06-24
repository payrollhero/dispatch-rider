module DispatchRider
  module Logging
    class Translator

      class CompleteTranslator < BaseTranslator
        def initialize(message, duration:)
          super(message)
          @duration = duration
        end

        def translate
          message_info_fragment(@message).merge duration: @duration
        end
      end

    end
  end
end
