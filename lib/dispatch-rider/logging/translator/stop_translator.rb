# frozen_string_literal: true

module DispatchRider
  module Logging
    class Translator
      class StopTranslator < BaseTranslator
        def initialize(message, reason:)
          super(message)
          @reason = reason
        end

        def translate
          message_info_fragment(@message).merge reason: @reason
        end
      end
    end
  end
end
