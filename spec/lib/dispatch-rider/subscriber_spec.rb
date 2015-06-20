require "spec_helper"

describe DispatchRider::Subscriber do

  before do
    allow(DispatchRider::Handlers::Base).to receive(:subclasses) { Set.new }

    konst = Class.new(DispatchRider::Handlers::Base) do
      def process(_options)
        throw :process_was_called
      end
    end
    stub_const("FooBar", konst)
  end

  describe "#initialize" do
    it "should assign a new queue service registrar" do
      expect(subject.queue_service_registrar.store).to be_empty
    end
  end

  describe "#register_queue" do
    it "should register a queue service with the queue service registrar" do
      subject.register_queue(:simple)
      expect(subject.queue_service_registrar.fetch(:simple)).to be_empty
    end
  end

  describe "#register_handler" do
    it "should register a handler" do
      subject.register_handler(:foo_bar)
      expect {
        message = DispatchRider::Message.new(subject: :foo_bar, body: { 'foo' => 'bar' })
        subject.dispatcher.dispatch(message)
      }.to throw_symbol(:process_was_called)
    end
  end

  describe "#register_handlers" do
    it "should register all the handlers" do
      subject.register_handlers(:foo_bar)
      expect {
        message = DispatchRider::Message.new(subject: :foo_bar, body: { 'foo' => 'bar' })
        subject.dispatcher.dispatch(message)
      }.to throw_symbol(:process_was_called)
    end
  end

  describe "#setup_demultiplexer" do
    context "when a queue is registered" do
      before :each do
        subject.register_queue(:simple)
        subject.register_handler(:foo_bar)
      end

      it "should assign a demultiplexer" do
        subject.setup_demultiplexer(:simple)
        expect(subject.demultiplexer.queue).to be_empty
        expect(subject.demultiplexer.dispatcher.fetch(:foo_bar)).to eq(FooBar)
      end
    end
  end

  describe "#process" do
    before :each do
      subject.register_queue(:simple)
      subject.register_handler(:foo_bar)
      subject.setup_demultiplexer(:simple)
    end

    describe "processing" do
      before do
        message = DispatchRider::Message.new(subject: :foo_bar, body: { 'baz' => 'blah' })
        subject.queue_service_registrar.fetch(:simple).push(message)
      end

      it "should process the queue" do
        expect { subject.process }.to throw_symbol(:process_was_called)
      end
    end

    # kills travis sometimes so leaving it here as tested documentation
    describe "process termination", if: false do
      before { allow(subject.demultiplexer).to receive(:stop) { throw :got_stopped } }

      context "when process quits" do
        before do
          konst = Class.new(DispatchRider::Handlers::Base) do
            def process(_options)
              Process.kill("QUIT", 0)
            end
          end
          stub_const("Quiter", konst)

          subject.register_handler(:quiter)
          message = DispatchRider::Message.new(subject: :quiter, body: {})
          subject.queue_service_registrar.fetch(:simple).push(message)
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process terminates" do
        before do
          konst = Class.new(DispatchRider::Handlers::Base) do
            def process(_options)
              Process.kill("TERM", 0)
            end
          end
          stub_const("Terminator", konst)
          subject.register_handler(:terminator)
          message = DispatchRider::Message.new(subject: :terminator, body: {})
          subject.queue_service_registrar.fetch(:simple).push(message)
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process is interupted" do
        before do
          konst = Class.new(DispatchRider::Handlers::Base) do
            def process(_options)
              Process.kill("INT", 0)
            end
          end
          stub_const("Interupter", konst)
          subject.register_handler(:interupter)
          message = DispatchRider::Message.new(subject: :interupter, body: {})
          subject.queue_service_registrar.fetch(:simple).push(message)
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process is interupted twice" do
        before do
          allow(subject.demultiplexer).to receive(:stop) # do nothing just ignore the interuption
          allow(subject).to receive(:exit) { throw :got_forcefully_stopped }

          konst = Class.new(DispatchRider::Handlers::Base) do
            def process(options)
              2.times { Process.kill("INT", 0) }
            end
          end
          stub_const("TwiceInterupter", konst)
          subject.register_handler(:twice_interupter)
          message = DispatchRider::Message.new(subject: :twice_interupter, body: {})
          subject.queue_service_registrar.fetch(:simple).push(message)
        end

        example { expect { subject.process }.to throw_symbol(:got_forcefully_stopped) }
      end
    end
  end

end
