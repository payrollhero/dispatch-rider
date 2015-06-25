$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Bundler.require

require 'aws'
require 'rake'
require 'tempfile'

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

  config.before do
    DispatchRider.config.logger = NullLogger.new
  end

  config.include FactoryGirl::Syntax::Methods
end

# Airbrake dummy module
module Airbrake
end
