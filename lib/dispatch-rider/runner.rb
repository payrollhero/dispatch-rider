module DispatchRider
  class Runner
    def initialize(queue)
      @demultiplexer = DispatchRider::Demultiplexer.new(queue)
    end

    def run
      interuption_count = 0
      Signal.trap("INT") do
        interuption_count += 1
        interuption_count < 2 ? @demultiplexer.stop : exit(0)
      end
      @demultiplexer.start
    end
  end
end
