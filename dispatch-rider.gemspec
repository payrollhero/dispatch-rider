# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: dispatch-rider 1.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dispatch-rider"
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Suman Mukherjee", "Dane Natoli", "Piotr Banasik", "Ronald Maravilla"]
  s.date = "2015-03-10"
  s.description = "Messaging system that is customizable based on which queueing system we are using."
  s.email = ["suman@payrollhero.com", "dnatoli@payrollhero.com", "piotr@payrollhero.com", "rmaravilla@payrollhero.com"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "lib/dispatch-rider.rb",
    "lib/dispatch-rider/callbacks.rb",
    "lib/dispatch-rider/callbacks/access.rb",
    "lib/dispatch-rider/callbacks/storage.rb",
    "lib/dispatch-rider/command.rb",
    "lib/dispatch-rider/configuration.rb",
    "lib/dispatch-rider/debug.rb",
    "lib/dispatch-rider/demultiplexer.rb",
    "lib/dispatch-rider/dispatcher.rb",
    "lib/dispatch-rider/error_handlers.rb",
    "lib/dispatch-rider/errors.rb",
    "lib/dispatch-rider/handlers.rb",
    "lib/dispatch-rider/handlers/base.rb",
    "lib/dispatch-rider/handlers/inheritance_tracking.rb",
    "lib/dispatch-rider/handlers/named_process.rb",
    "lib/dispatch-rider/integrations/appsignal.rb",
    "lib/dispatch-rider/message.rb",
    "lib/dispatch-rider/notification_services.rb",
    "lib/dispatch-rider/notification_services/aws_sns.rb",
    "lib/dispatch-rider/notification_services/base.rb",
    "lib/dispatch-rider/notification_services/file_system.rb",
    "lib/dispatch-rider/notification_services/file_system/channel.rb",
    "lib/dispatch-rider/notification_services/file_system/notifier.rb",
    "lib/dispatch-rider/publisher.rb",
    "lib/dispatch-rider/publisher/base.rb",
    "lib/dispatch-rider/publisher/configuration.rb",
    "lib/dispatch-rider/publisher/configuration/destination.rb",
    "lib/dispatch-rider/publisher/configuration/notification_service.rb",
    "lib/dispatch-rider/publisher/configuration_reader.rb",
    "lib/dispatch-rider/publisher/configuration_support.rb",
    "lib/dispatch-rider/queue_services.rb",
    "lib/dispatch-rider/queue_services/aws_sqs.rb",
    "lib/dispatch-rider/queue_services/aws_sqs/message_body_extractor.rb",
    "lib/dispatch-rider/queue_services/aws_sqs/sqs_received_message.rb",
    "lib/dispatch-rider/queue_services/base.rb",
    "lib/dispatch-rider/queue_services/file_system.rb",
    "lib/dispatch-rider/queue_services/file_system/fs_received_message.rb",
    "lib/dispatch-rider/queue_services/file_system/queue.rb",
    "lib/dispatch-rider/queue_services/received_message.rb",
    "lib/dispatch-rider/queue_services/simple.rb",
    "lib/dispatch-rider/registrars.rb",
    "lib/dispatch-rider/registrars/base.rb",
    "lib/dispatch-rider/registrars/file_system_channel.rb",
    "lib/dispatch-rider/registrars/handler.rb",
    "lib/dispatch-rider/registrars/notification_service.rb",
    "lib/dispatch-rider/registrars/publishing_destination.rb",
    "lib/dispatch-rider/registrars/queue_service.rb",
    "lib/dispatch-rider/registrars/sns_channel.rb",
    "lib/dispatch-rider/runner.rb",
    "lib/dispatch-rider/subscriber.rb",
    "lib/dispatch-rider/version.rb",
    "lib/generators/dispatch_rider/install/USAGE",
    "lib/generators/dispatch_rider/install/install_generator.rb",
    "lib/generators/dispatch_rider/install/templates/script/dispatch_rider",
    "lib/generators/dispatch_rider/job/USAGE",
    "lib/generators/dispatch_rider/job/dispatch_job_generator.rb",
    "lib/generators/dispatch_rider/job/templates/handler/handler.rb.erb",
    "lib/generators/dispatch_rider/job/templates/handler/handler_spec.rb.erb",
    "lib/generators/dispatch_rider/job/templates/publisher/publisher.rb.erb",
    "lib/generators/dispatch_rider/job/templates/publisher/publisher_spec.rb.erb"
  ]
  s.homepage = "https://github.com/payrollhero/dispatch-rider"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Messaging system based on the reactor patter. You can publish messages to a queue and then a demultiplexer runs an event loop which pops items from the queue and hands it over to a dispatcher. The dispatcher hands over the message to the appropriate handler. You can choose your own queueing service."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<activemodel>, [">= 0"])
      s.add_runtime_dependency(%q<daemons>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<travis-lint>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<byebug>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<activemodel>, [">= 0"])
      s.add_dependency(%q<daemons>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<travis-lint>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<byebug>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<activemodel>, [">= 0"])
    s.add_dependency(%q<daemons>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<travis-lint>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<byebug>, [">= 0"])
  end
end

