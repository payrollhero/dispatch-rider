module DispatchRider
  module Registrars
    class Base
      attr_reader :store

      def initialize
        @store = {}
      end

      def register(name, options = {})
        store[name.to_sym] = value(name, options)
        self
      rescue NameError
        raise NotFound.new(name)
      end

      def value(name, options = {})
        raise NotImplementedError
      end

      def unregister(name)
        store.delete(name.to_sym)
        self
      end

      def fetch(name)
        begin
          store.fetch(name.to_sym)
        rescue IndexError
          raise NotRegistered.new(name)
        end
      end
    end
  end
end
