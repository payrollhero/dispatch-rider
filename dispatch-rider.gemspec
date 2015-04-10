# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dispatch-rider/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "dispatch-rider"
  gem.version = DispatchRider::VERSION

  gem.summary = %q{
    Messaging system that is customizable based on which
    queueing system we are using.
  }
  gem.description = %q{
    Messaging system based on the reactor pattern.

    You can publish messages to a queue and then a demultiplexer
    runs an event loop which pops items from the queue and hands
    it over to a dispatcher.

    The dispatcher hands over the message to the appropriate
    handler.

    You can choose your own queueing service.
  }
  gem.license = "MIT"
  gem.authors = [
    "Suman Mukherjee",
    "Dane Natoli",
    "Piotr Banasik",
    "Ronald Maravilla",
  ]
  gem.email = [
    "piotr@payrollhero.com",
    "rmaravilla@payrollhero.com",
  ]
  gem.homepage = "https://github.com/payrollhero/dispatch-rider"
  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'activesupport', "~> 4", ">= 3.2.0"
  gem.add_runtime_dependency 'activemodel', "~> 4", ">= 3.2.0"
  gem.add_runtime_dependency 'daemons', "~> 1.2"
  gem.add_runtime_dependency 'retries', "~> 0.0", ">= 0.0.5"
end
