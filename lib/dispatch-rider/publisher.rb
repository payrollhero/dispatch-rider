module DispatchRider
  class Publisher

    def initialize(queue)
      @queue = queue
    end

    def publish(attrs)
      @queue.push DispatchRider::Message.new(attrs)
    end

  end
end
