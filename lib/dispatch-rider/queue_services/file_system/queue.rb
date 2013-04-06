module DispatchRider
  module QueueServices
    # This is a rudementary queue service that uses file system instead of
    # AWS::SQS or SimpleQueue. It addresses SimpleQueue's inability to be used
    # by only one application instance while avoid the cost of setting up AWS::SQS.
    # This is ideal to be used inside development.
    class FileSystem < Base
      class Queue
        def initialize(path)
          FileUtils.mkdir_p(path)
          @path = path
        end

        def add(item)
          name_base = "#{@path}/#{Time.now.to_f}"
          File.open("#{name_base}.inprogress", "w") {|f|
            f.write(item)
          }
          FileUtils.mv("#{name_base}.inprogress", "#{name_base}.ready")
        end

        def pop
          file_path = file_paths.first
          return nil unless file_path
          file_path_inflight = file_path.gsub(/\.ready$/, '.inflight')
          FileUtils.mv(file_path, file_path_inflight)
          file = File.new(file_path_inflight)
          file
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