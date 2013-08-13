#!env ruby

require './config/boot'
require 'dispatch-rider'
require 'dispatch-rider/command'

DispatchRider::Command.new.run(ARGV) do
  require './config/environment'
  DispatchRider::Runner.run # your application's custom runner class example
end
