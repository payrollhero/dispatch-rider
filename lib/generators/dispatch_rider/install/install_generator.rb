# frozen_string_literal: true

module DispatchRider
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    def create_scripts
      copy_file "script/dispatch_rider", "script/dispatch_rider"
      chmod 'script/dispatch_rider', 0o755
    end
  end
end
