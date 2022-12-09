# frozen_string_literal: true

# This is the registrar for FileSystem channels, basically storing paths

module DispatchRider
  module Registrars
    class FileSystemChannel < Base
      def value(_name, options = {})
        File.expand_path(options[:path])
      end
    end
  end
end
