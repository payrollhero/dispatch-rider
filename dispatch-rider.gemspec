# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dispatch-rider/version'

Gem::Specification.new do |spec|
  spec.name          = "dispatch-rider"
  spec.version       = DispatchRider::VERSION
  spec.authors       = ["Suman Mukherjee"]
  spec.email         = ["sumanmukherjee03@gmail.com"]
  spec.description   = %q{Messaging system that is customizable based on which queueing system we are using.}
  spec.summary       = %q{Messaging system based on the reactor patter.
    You can publish messages to a queue and then a demultiplexer runs an event loop which pops items from the queue and hands it over to a dispatcher.
    The dispatcher hands over the message to the appropriate handler. You can choose your own queueing service.
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb']

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "gemfury"
  spec.add_development_dependency "json"
end
