$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'aws'
require 'rails'
require 'rake'

module DispatchRider
  class Application < ::Rails::Application
  end
end

DispatchRider::Application.initialize!

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'
  config.color_enabled = true
  config.tty = true
end

require 'dispatch-rider.rb'
