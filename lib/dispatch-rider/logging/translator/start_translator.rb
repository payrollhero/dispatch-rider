module DispatchRider
  module Logging
    class Translator
      class StartTranslator < BaseTranslator
        def translate
          message_info_fragment(@message)
        end
      end
    end
  end
end
