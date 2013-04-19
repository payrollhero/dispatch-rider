# This is the external interface to the gem that is accessible to the clients
# The clients have to initiate a queue, setup the publisher, dispatcher and demultiplexer.
# They need to register their handlers with the dispatcher through this interface as well.
# When all is setup, the clients can publish through the publisher and subscribe by starting the demultiplexer.
module DispatchRider
  module Reactor
  end
end

require "reactor/publisher"
require "reactor/subscriber"
