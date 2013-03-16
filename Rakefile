require "bundler/gem_tasks"
require "yaml"

task :push do
  Bundler.require :default, "development"
  gemfury_config = YAML.load_file(File.expand_path("~/.gem/gemfury"))

  gem_name = File.basename(Dir["*.gemspec"].first).gsub(/\.gemspec$/, '')

  version_file_name = "lib/#{gem_name}/version.rb"
  system "$EDITOR #{version_file_name}"
  Rake::Task[:build].invoke

  load version_file_name
  version = DispatchRider::VERSION

  fn = File.expand_path("pkg/#{gem_name}-#{version}.gem")

  client = Gemfury::Client.new(:user_api_key => gemfury_config[:gemfury_api_key], :account => "payrollhero")
  puts "sending: #{File.basename(fn)} ..."
  File.open(fn) { |fh|
    client.push_gem(fh)
  }
  puts "Done"
end
