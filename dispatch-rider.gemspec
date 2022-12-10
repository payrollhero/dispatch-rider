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
    "Mathieu Jobin",
  ]
  gem.email = [
    "mathieu@payrollhero.com",
  ]
  gem.homepage = 'https://github.com/payrollhero/dispatch-rider'
  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.7.2'


  gem.add_runtime_dependency 'activesupport', '>= 5.2.0'
  gem.add_runtime_dependency 'activemodel', '>= 5.2.0'
  gem.add_runtime_dependency 'activerecord', '>= 5.2.0'
  gem.add_runtime_dependency 'aws-sdk-sqs', '~> 1.30'
  gem.add_runtime_dependency 'aws-sdk-sns', '~> 1.30'
  gem.add_runtime_dependency 'daemons', '~> 1.2'
  gem.add_runtime_dependency 'retriable', '~> 3.1', '>= 3.1.2'
  # appsignal is an optional runtime dependency,
  # I am marking it as development for those that don't need it
  gem.add_development_dependency 'appsignal', '~> 1.0'

  gem.add_development_dependency 'bundler', '< 3.0'
  gem.add_development_dependency 'coveralls_reborn', '~> 0.25'
  gem.add_development_dependency 'simplecov-lcov'
  gem.add_development_dependency 'debug'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'github_changelog_generator'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'factory_bot'

  # static analysis gems
  gem.add_development_dependency 'rubocop_challenger'
end
