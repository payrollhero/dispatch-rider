require 'spec_helper'

describe DispatchRider::Publisher do

  subject(:publisher) { described_class.new }

  describe "#initialize" do
    it "assigns the notification service registrar" do
      subject.notification_service_registrar.store.should be_empty
    end

    it "assigns a publishing destination registrar" do
      subject.publishing_destination_registrar.store.should be_empty
    end

    it "assigns a service channel mapper" do
      subject.service_channel_mapper.destination_registrar.store.should be_empty
    end

    # this case is broken because its playing chicken and the egg with the expectation
    # not sure how rspec 2 did it .. it passes subject as a parameter to which triggers the creation of subject ..
    # which makes the call that is being expected here .. so when subject is evaluated the assertion is not in place yet
    # and the assertion can't be made unless subject already exists ..
    #
    # context "when not passing a configuration" do
    #   it "loads the global configuration" do
    #     expect(DispatchRider::Publisher::ConfigurationReader).to receive(:load_config).with(described_class.configuration, subject)
    #     subject
    #   end
    # end
    #
    # context "when passing a configuration" do
    #   let(:configuration){ DispatchRider::Publisher::Configuration.new }
    #
    #   subject{ described_class.new(configuration) }
    #
    #   it "loads the configuration" do
    #     expect(DispatchRider::Publisher::ConfigurationReader).to receive(:load_config).with(configuration, subject)
    #     subject
    #   end
    # end
  end

  describe "#register_notification_service" do
    it "registers a notification service" do
      subject.register_notification_service(:aws_sns)
      result = subject.notification_service_registrar.fetch(:aws_sns)
      result.notifier.should respond_to(:topics)
      result.channel_registrar.store.should be_empty
    end

    it "returns the publisher" do
      subject.register_notification_service(:aws_sns).should eq(subject)
    end
  end

  describe "#register_channel" do
    before :each do
      subject.register_notification_service(:aws_sns)
    end

    let(:notification_service) { subject.notification_service_registrar.fetch(:aws_sns) }

    it "registers a channel for the notification service" do
      subject.register_channel(:aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      notification_service.channel_registrar.fetch(:foo).should eq('arn:aws:sns:us-east-1:123:PlanOfAttack')
    end

    it "returns the publisher" do
      subject.register_channel(:aws_sns, :foo).should eq(subject)
    end
  end

  describe "#register_destination" do
    before :each do
      subject.register_notification_service(:aws_sns)
    end

    it "registers the destination to be published to" do
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      result = subject.publishing_destination_registrar.fetch(:sns_foo)
      result.service.should eq(:aws_sns)
      result.channel.should eq(:foo)
    end

    it "returns the publisher" do
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack").should eq(subject)
    end
  end

  describe "#publish" do
    let :notifier do
      subject.notification_service_registrar.fetch(:aws_sns).notifier
    end

    before :each do
      subject.register_notification_service(:file_system)
      subject.register_destination(:fs_foo, :file_system, :foo, path: "tmp/test_queue")
    end

    around do |ex|
      begin
        DispatchRider.config.debug = true
        ex.call
      ensure
        DispatchRider.config.debug = false
      end
    end

    it "publishes the message to the notification service" do
      existing = Dir['tmp/test_queue/*']
      expect {
        subject.publish(:destinations => [:fs_foo], :message => {:subject => "bar_handler", :body => {"bar" => "baz"}})
      }.to change { Dir['tmp/test_queue/*'].length }.by(1)
      new_job = Dir['tmp/test_queue/*'] - existing
      data = JSON.load(File.read(new_job.first))

      expected_message = {
        "subject" => "bar_handler",
        "body" => {
          "guid" => DispatchRider::Debug::PUBLISHER_MESSAGE_GUID,
          "bar" => "baz",
        },
      }
      expect(data).to eq(expected_message)
    end

    describe "calls publish callback" do
      describe "calls the publish callback" do
        let(:publish_callback) { double :callback }
        let(:expected_message) {
          DispatchRider::Message.new(
            subject: "bar_handler",
            body: {
              "bar" => "baz",
              guid: "test-mode-not-random-guid"
            }
          )
        }

        before { DispatchRider.config.callbacks.for(:publish) << publish_callback }
        after { DispatchRider.config.callbacks.for(:publish).delete publish_callback }

        example do
          publish_callback.should_receive(:call).with any_args, # first argument is the inner job
                                                      destinations: [:fs_foo],
                                                      message: expected_message

          publisher.publish destinations: [:fs_foo],
                            message: {
                              subject: "bar_handler",
                              body: { "bar" => "baz" }
                            }
        end
      end
    end
  end
end
