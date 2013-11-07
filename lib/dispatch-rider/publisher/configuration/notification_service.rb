module DispatchRider
  class Publisher::Configuration::NotificationService

    def initialize(name, options)
      @name = name
      @options = options
    end

    attr_reader :name, :options

    def ==(other)
      self.name == other.name &&
        self.options == other.options
    end

  end
end
