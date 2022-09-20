# frozen_string_literal: true

module DispatchRider
  module Logging
    class Translator
      class FailTranslator < BaseTranslator
        def initialize(message, exception:)
          super(message)
          @exception = exception
        end

        def translate
          exception_info_fragment(@message, @exception)
        end
      end
    end
  end
end
