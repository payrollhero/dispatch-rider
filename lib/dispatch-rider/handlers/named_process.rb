# frozen_string_literal: true

module DispatchRider
  module Handlers
    module NamedProcess
      def with_named_process(message)
        original_program_name = $PROGRAM_NAME
        begin
          $0 += " - #{message.subject} (#{message.body['guid']})"
          yield
        ensure
          $0 = original_program_name
        end
      end
    end
  end
end
