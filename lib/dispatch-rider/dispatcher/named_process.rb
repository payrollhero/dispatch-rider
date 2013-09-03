module DispatchRider
  module Dispatcher::NamedProcess
    def with_named_process(subject)
      original_program_name = $0
      begin
        $0 += " - #{subject}"
        yield
      ensure
        $0 = original_program_name
      end
    end
  end
end
