$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'aws'
require 'rake'
require 'tempfile'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
  config.color_enabled = true
  config.tty = true
end

# Airbrake dummy module
module Airbrake; end

require 'dispatch-rider.rb'
