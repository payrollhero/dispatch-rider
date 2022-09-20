# frozen_string_literal: true

require 'daemons'
require 'pathname'
require 'optparse'

module DispatchRider
  class Command
    def initialize(options = {})
      @app_home = Pathname.new(Dir.getwd)
      @options = {
        :log_output => true,
        :dir_mode => :normal,
        :log_dir => (@app_home + "log").to_s,
        :dir => (@app_home + "log").to_s,
        :multiple => false,
        :monitor => false,
        :identifier => 0,
      }.merge(options)
    end

    def run(args, &block)
      process_args(args)

      process_name = "dispatch_rider.#{@options[:identifier]}"
      Daemons.run_proc(process_name, @options) do
        $0 = File.join(@options[:prefix], process_name) if @options[:prefix]
        Dir.chdir(@app_home.to_s) do
          block.call
        end
      end
    end

  private

    def process_args(args)
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] start|stop|restart|run"
        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
        opts.on('-i', '--identifier=n', 'A numeric identifier for the worker.') do |n|
          @options[:identifier] = n
        end
        opts.on('-m', '--monitor', 'Start monitor process.') do
          @options[:monitor] = true
        end
        opts.on('-p', '--prefix NAME', "String to be prefixed to worker process names") do |prefix|
          @options[:prefix] = prefix
        end
      end
      @opts = opts.parse!(args)
    end
  end
end
