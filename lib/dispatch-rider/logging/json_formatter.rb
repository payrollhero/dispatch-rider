# frozen_string_literal: true

require 'json'

# JSON Log Formatter
module DispatchRider
  module Logging
    class JsonFormatter
      def format(data)
        data.to_json
      end
    end
  end
end
