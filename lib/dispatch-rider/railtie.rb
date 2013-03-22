module DispatchRider
  class Railtie < ::Rails::Railtie
    config.dispatch_rider = DispatchRider::Reactor.new

    rake_tasks do
      load File.expand_path("../tasks/dispatch_rider.rake", __FILE__)
    end
  end
end
