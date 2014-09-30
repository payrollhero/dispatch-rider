module SignalTools
  def self.append_trap(signal, &block)
    old_handler = trap(signal) do
      block.call
      old_handler.call if old_handler.respond_to?(:call)
    end
  end
end
