module DispatchRider
  module Logging
    # Translates a message into a loggable hash based on its result.
    class Translator
      def self.translate(message, kind, **args)
        klass = translator_class(kind)
        fragment = klass.new(message, **args).translate
        { phase: kind }.merge fragment
      end

      def self.translator_class(kind)
        const_get("#{kind}_translator".classify)
      end
    end
  end
end

require_relative 'translator/base_translator'
require_relative 'translator/complete_translator'
require_relative 'translator/fail_translator'
require_relative 'translator/error_handler_fail_translator'
require_relative 'translator/start_translator'
require_relative 'translator/stop_translator'
require_relative 'translator/success_translator'
