# This class is the abstraction to which the clients publish their messages.
# This class is present to cut out the direct dependency on the queue.
module DispatchRider
  class Publisher
    attr_reader :queue

    def initialize(queue)
      @queue = queue
    end

    def publish(attrs)
      queue.push DispatchRider::Message.new(attrs)
    end
  end
end
