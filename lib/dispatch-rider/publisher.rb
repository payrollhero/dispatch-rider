module DispatchRider
  class Publisher
    def initialize(queue)
      @queue = queue
    end

    def publish(attrs)
      @queue.push construct_message(attrs)
    end

    private

    def construct_message(attrs)
      DispatchRider::Message.new(attrs)
    end
  end
end
