# frozen_string_literal: true

require 'spec_helper'

describe "Logging" do
  let(:publisher) { setup_publisher }
  let(:subscriber) { setup_subscriber }

  let(:mock_logger_class) do
    Class.new {
      def initialize
        @log = []
      end

      attr_reader :log

      def info(message)
        @log << { level: :info, message: message }
      end

      def error(message)
        @log << { level: :error, message: message }
      end
    }
  end

  let(:mock_logger) { mock_logger_class.new }

  before do
    purge_test_queue
    DispatchRider.config.log_formatter = DispatchRider::Logging::JsonFormatter.new
    DispatchRider.config.logger = mock_logger
    DispatchRider.config.debug = true
  end

  after do
    DispatchRider.clear_configuration!
  end

  context "successful handler" do
    before do
      publisher.publish message: { subject: 'sample_handler', body: {} }, destinations: :dst
      work_off_jobs(subscriber)
    end

    example "full logging integration in json mode" do
      expected1 = {
        'phase' => 'start',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'sample_handler',
        'body' => {},
      }

      expected2 = {
        'phase' => 'success',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'sample_handler',
        'body' => {},
      }

      expected3 = {
        'phase' => 'complete',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'sample_handler',
        'body' => {},
      }

      expect(mock_logger.log.count).to eq(3)

      expect(mock_logger.log[0]).to eq(level: :info, message: expected1.to_json)
      expect(mock_logger.log[1]).to eq(level: :info, message: expected2.to_json)

      # last one is a bit harder since it has a relative 'duration' value
      entry = mock_logger.log[2]
      expect(entry[:level]).to eq(:info)
      payload = JSON.parse(entry[:message])
      expect(payload['duration']).to be_a(Numeric)
      payload.delete 'duration'
      expect(payload).to eq(expected3)
    end
  end

  context "failing handler" do
    before do
      publisher.publish message: { subject: 'crashing_handler', body: {} }, destinations: :dst
      work_off_jobs(subscriber, fail_on_error: false)
    end

    example "full logging integration in json mode" do
      expected1 = {
        'phase' => 'start',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'crashing_handler',
        'body' => {},
      }

      expected2 = {
        'phase' => 'fail',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'crashing_handler',
        'body' => {},
        'exception' => {
          'class' => 'RuntimeError',
          'message' => 'I crashed!',
        },
      }

      expected3 = {
        'phase' => 'complete',
        'guid' => 'test-mode-not-random-guid',
        'subject' => 'crashing_handler',
        'body' => {},
      }

      expect(mock_logger.log.count).to eq(3)

      expect(mock_logger.log[0]).to eq(level: :info, message: expected1.to_json)
      expect(mock_logger.log[1]).to eq(level: :error, message: expected2.to_json)

      # last one is a bit harder since it has a relative 'duration' value
      entry = mock_logger.log[2]
      expect(entry[:level]).to eq(:info)
      payload = JSON.parse(entry[:message])
      expect(payload['duration']).to be_a(Numeric)
      payload.delete 'duration'
      expect(payload).to eq(expected3)
    end
  end
end
