module DispatchRider
  class Runner
    def self.run
      interuption_count = 0
      demultiplexer = DispatchRider::Demultiplexer.new(Rails.application.dispatch_queue)
      Signal.trap("INT") do
        interuption_count += 1
        if interuption_count < 2
          puts "Stopping demultiplexer... Interupt again to forcefully terminate."
          demultiplexer.stop
        else
          puts "Forced termination!!!"
          exit
        end
      end
      puts "Running demultiplexer..."
      demultiplexer.start # blocked till stopped
      puts "Stopped demultiplexer..."
    end
  end
end
