# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.minimum_coverage 85
require 'coveralls'

if RUBY_VERSION < "3.1"
  SimpleCov.start 'rails' do
    if ENV['CI']
      require 'simplecov-lcov'

      SimpleCov::Formatter::LcovFormatter.config do |c|
        c.report_with_single_file = true
        c.single_report_path = 'coverage/lcov.info'
      end

      formatter SimpleCov::Formatter::LcovFormatter
    end

    add_filter '/bin/'
    add_filter '/script/'
    add_filter '/db/'
    add_filter '/spec/' # for rspec
    add_filter '/test/' # for minitest
  end

  Coveralls.wear!('rails')
end

Bundler.setup
Bundler.require(:default, :development)

require 'dispatch-rider'

Dir['./spec/support/**/*.rb'].sort.each { |fn| require(fn) }

FactoryBot.definition_file_paths = %w{spec/factories/}
FactoryBot.find_definitions

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec
  config.order = 'random'
  config.color = true
  config.tty = true
  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
  end

  config.include IntegrationSupport

  config.before(:suite) do
    FileUtils.mkdir_p "tmp"
    FileUtils.rm_f "tmp/lite.db"
    FileUtils.rm_rf "spectmp"
    SQLite3::Database.new "tmp/lite.db"
    ActiveRecord::Base.establish_connection adapter: :sqlite3, database: File.dirname(__FILE__) + "tmp/lite.db"
    ActiveRecord::Schema.define(version: 1) do
      extend DispatchRider::ScheduledJob::Migration
      create_scheduled_jobs_table
    end
  end

  config.before do
    DispatchRider.config.logger = NullLogger.new
  end

  config.after do
    DispatchRider::ScheduledJob.destroy_all
  end

  config.include FactoryBot::Syntax::Methods
end

# Airbrake dummy module
module Airbrake
end
