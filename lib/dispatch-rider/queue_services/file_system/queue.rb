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
          file_path = file_paths.first
          return nil unless file_path
          file_path_inflight = file_path.gsub(/\.ready$/, '.inflight')
          FileUtils.mv(file_path, file_path_inflight)
          File.new(file_path_inflight)
        end

        def remove(item)
          item.close
          File.unlink(item.path)
        end

        def size
          file_paths.size
        end

        private

        def file_paths
          Dir["#{@path}/*.ready"]
        end
      end
    end
  end
end
