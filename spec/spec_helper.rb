require 'bundler'

Bundler.setup
Bundler.require(:default, :development)

require 'dispatch-rider'

Dir['./spec/support/**/*.rb'].each { |fn| require(fn) }

FactoryGirl.definition_file_paths = %w{spec/factories/}
FactoryGirl.find_definitions

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

  config.include FactoryGirl::Syntax::Methods
end

# Airbrake dummy module
module Airbrake
end
