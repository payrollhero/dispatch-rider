# frozen_string_literal: true

# This is a queue implementation for the queue service based on file systems
module DispatchRider
  module QueueServices
    class FileSystem < Base
      class Queue
        def initialize(path)
          FileUtils.mkdir_p(path)
          @path = path
        end

        def add(item)
          name_base = "#{@path}/#{Time.now.to_f}"
          File.open("#{name_base}.inprogress", "w"){ |f| f.write(item) }
          FileUtils.mv("#{name_base}.inprogress", "#{name_base}.ready")
        end

        def pop
          file_path = next_item(10)
          return nil unless file_path
          file_path_inflight = file_path.gsub(/\.ready$/, '.inflight')
          FileUtils.mv(file_path, file_path_inflight)
          File.new(file_path_inflight)
        end

        def put_back(item)
          add(item)
          remove(item)
        end

        def remove(item)
          item.close
          File.unlink(item.path)
        end

        def size
          file_paths.size
        end

        private

        # Long polling next item fetcher
        # allows to sleep between checks for a new file and not run the main loop as much
        def next_item(timeout = 10.seconds)
          Timeout.timeout(timeout) do
            sleep 1 until file_paths.first
            file_paths.first
          end
        rescue Timeout::Error
          nil
        end

        def file_paths
          Dir["#{@path}/*.ready"]
        end
      end
    end
  end
end
