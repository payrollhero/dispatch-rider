# frozen_string_literal: true

class DispatchJob < Rails::Generators::Base
  class Publisher < Rails::Generators::Base
    source_root File.expand_path('../templates/publisher', __FILE__)
    argument :handler_name, type: :string, required: true
    argument :publisher_name, type: :string, required: true

    class Rspec < Rails::Generators::Base
      source_root File.expand_path('../templates/publisher', __FILE__)
      argument :handler_name, type: :string, required: true
      argument :publisher_name, type: :string, required: true

      def generate_publisher_spec
        template "publisher_spec.rb.erb", "spec/publishers/#{publisher_name}_spec.rb"
      end
    end

    def generate_publisher
      template "publisher.rb.erb", "app/publishers/#{publisher_name}.rb"
    end

    hook_for :test_framework, in: "dispatch_job:publisher"
  end

  class Handler < Rails::Generators::Base
    source_root File.expand_path('../templates/handler', __FILE__)
    argument :handler_name, type: :string, required: true

    class Rspec < Rails::Generators::Base
      source_root File.expand_path('../templates/handler', __FILE__)
      argument :handler_name, type: :string, required: true

      def generate_handler_spec
        template "handler_spec.rb.erb", "spec/handlers/#{handler_name}_spec.rb"
      end
    end

    def generate_handler
      template "handler.rb.erb", "app/handlers/#{handler_name}.rb"
    end

    hook_for :test_framework, in: "dispatch_job:handler"
  end

  # source_root File.expand_path('../templates', __FILE__)

  class_option :publisher, default: :publisher, hide: true
  class_option :handler, default: :handler, hide: true

  argument :handler_name, type: :string

  hook_for :publisher do |publisher|
    invoke publisher, [handler_name, handler_name.underscore + "_publisher"]
  end

  hook_for :handler do |handler|
    invoke handler, [handler_name]
  end
end
