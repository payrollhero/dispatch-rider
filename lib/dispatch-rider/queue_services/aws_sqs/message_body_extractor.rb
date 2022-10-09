# frozen_string_literal: true

module DispatchRider
  module QueueServices
    class AwsSqs < Base
      class MessageBodyExtractor
        attr_reader :parsed_message

        def initialize(raw_message)
          @parsed_message = JSON.parse(raw_message.body)
        end

        def extract
          parsed_message.has_key?("Message") ? parsed_message["Message"] : parsed_message.to_json
        end
      end
    end
  end
end
