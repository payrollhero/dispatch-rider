namespace :dispatch_rider do
  desc "Start dispatching messages"
  task :start => :environment do
    Rails.application.config.dispatch_rider.run
  end
end
