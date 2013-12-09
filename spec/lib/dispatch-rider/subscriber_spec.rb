require "spec_helper"

describe DispatchRider::Subscriber do

  before do
    DispatchRider::Handlers::Base.stub(:subclasses){ Set.new }

    stub_const("FooBar", Class.new(DispatchRider::Handlers::Base) {
      def process(options)
        throw :process_was_called
      end
    })
  end

  describe "#initialize" do
    it "should assign a new queue service registrar" do
      subject.queue_service_registrar.store.should be_empty
    end
  end

  describe "#register_queue" do
    it "should register a queue service with the queue service registrar" do
      subject.register_queue(:simple)
      subject.queue_service_registrar.fetch(:simple).should be_empty
    end
  end

  describe "#register_handler" do
    it "should register a handler" do
      subject.register_handler(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol(:process_was_called)
    end
  end

  describe "#register_handlers" do
    it "should register all the handlers" do
      subject.register_handlers(:foo_bar)
      expect { subject.dispatcher.dispatch(DispatchRider::Message.new(:subject => :foo_bar, :body => {'foo' => 'bar'})) }.to throw_symbol(:process_was_called)
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
        subject.demultiplexer.queue.should be_empty
        subject.demultiplexer.dispatcher.fetch(:foo_bar).should eq(FooBar)
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
        subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(subject: :foo_bar, body: {'baz' => 'blah'}))
      end

      it "should process the queue" do
        expect { subject.process }.to throw_symbol(:process_was_called)
      end
    end

    # kills travis sometimes so leaving it here as tested documentation
    describe "process termination", if: false do
      before { subject.demultiplexer.stub(:stop){ throw :got_stopped } }

      context "when process quits" do
        before do
          stub_const("Quiter", Class.new(DispatchRider::Handlers::Base) {
            def process(options)
              Process.kill("QUIT", 0)
            end
          })

          subject.register_handler(:quiter)
          subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(subject: :quiter, body: {}))
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process terminates" do
        before do
          stub_const("Terminator", Class.new(DispatchRider::Handlers::Base) {
            def process(options)
              Process.kill("TERM", 0)
            end
          })
          subject.register_handler(:terminator)
          subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(subject: :terminator, body: {}))
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process is interupted" do
        before do
          stub_const("Interupter", Class.new(DispatchRider::Handlers::Base) {
            def process(options)
              Process.kill("INT", 0)
            end
          })
          subject.register_handler(:interupter)
          subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(subject: :interupter, body: {}))
        end

        example { expect { subject.process }.to throw_symbol(:got_stopped) }
      end

      context "when process is interupted twice" do
        before do
          subject.demultiplexer.stub(:stop) # do nothing just ignore the interuption
          subject.stub(:exit){ throw :got_forcefully_stopped }

          stub_const("TwiceInterupter", Class.new(DispatchRider::Handlers::Base) {
            def process(options)
              2.times { Process.kill("INT", 0) }
            end
          })
          subject.register_handler(:twice_interupter)
          subject.queue_service_registrar.fetch(:simple).push(DispatchRider::Message.new(subject: :twice_interupter, body: {}))
        end

        example { expect { subject.process }.to throw_symbol(:got_forcefully_stopped) }
      end
    end
  end

  describe "#logger" do

    example { subject.logger.should respond_to(:info) }
    example { subject.logger.should respond_to(:warn) }
    example { subject.logger.should respond_to(:error) }

  end

  describe "#logger=" do

    let(:new_logger) { double(:logger) }

    example do
      subject.logger = new_logger
      subject.logger.should == new_logger
    end

  end

end
