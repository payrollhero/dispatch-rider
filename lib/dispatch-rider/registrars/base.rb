# This is the base class for the registrars.
#  It defines the interface that other registrars inherit.
#  This is an abstract class.
#  The child classes inheriting this interface must define the 'value' method.
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
        raise NotFound, name
      end

      def value(name, options = {})
        raise NotImplementedError
      end

      def unregister(name)
        store.delete(name.to_sym)
        self
      end

      def fetch(name)
        store.fetch(name.to_sym)
      rescue IndexError
        raise NotRegistered, name
      end
    end
  end
end
