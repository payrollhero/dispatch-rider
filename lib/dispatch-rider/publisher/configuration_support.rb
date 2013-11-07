module DispatchRider
  class Publisher
    module ConfigurationSupport

      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :config, :configuration

      def configure(configuration_hash = {})
        if block_given?
          yield configuration
        else
          configuration.parse(configuration_hash)
        end
      end

    end
  end
end
