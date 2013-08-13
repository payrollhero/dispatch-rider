# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
  Bundler.require(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

Jeweler::Tasks.new do |gem|
  def get_version_without_constant
    version_fn = 'lib/dispatch-rider/version.rb'
    r = eval "module TempVersionModule; #{File.read(version_fn)}; end", binding, version_fn
    Object.send(:remove_const, "TempVersionModule")
    r
  end
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "dispatch-rider"
  gem.version = get_version_without_constant

  gem.description = %q{Messaging system that is customizable based on which queueing system we are using.}
  gem.summary = %q{Messaging system based on the reactor patter.
    You can publish messages to a queue and then a demultiplexer runs an event loop which pops items from the queue and hands it over to a dispatcher.
    The dispatcher hands over the message to the appropriate handler. You can choose your own queueing service.
  }

  gem.homepage = ""
  gem.license = "MIT"
  gem.authors = ["Suman Mukherjee"]
  gem.email = ["sumanmukherjee03@gmail.com"]

  gem.executables = []

  gem.files = FileList[
    'bin/*',
    'lib/**/*.rb',
    'lib/tasks/**/*.rake',
  ]

  # dependencies defined in Gemfile
end

# remove some weird jeweler stuff
[
  'git:release',
  'gemspec:release',
].each do |task|
  Rake::Task[task].clear
  Rake::Task[task].clear_comments
end

