# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Publisher do

  subject(:publisher) { described_class.new }

  describe "#initialize" do
    it "assigns the notification service registrar" do
      expect(subject.notification_service_registrar.store).to be_empty
    end

    it "assigns a publishing destination registrar" do
      expect(subject.publishing_destination_registrar.store).to be_empty
    end

    it "assigns a service channel mapper" do
      expect(subject.service_channel_mapper.destination_registrar.store).to be_empty
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
      expect(result.notifier).to respond_to(:list_topics)
      expect(result.channel_registrar.store).to be_empty
    end

    it "returns the publisher" do
      expect(subject.register_notification_service(:aws_sns)).to eq(subject)
    end
  end

  describe "#register_channel" do
    before do
      subject.register_notification_service(:aws_sns)
    end

    let(:notification_service) { subject.notification_service_registrar.fetch(:aws_sns) }

    it "registers a channel for the notification service" do
      subject.register_channel(:aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      expect(notification_service.channel_registrar.fetch(:foo)).to eq('arn:aws:sns:us-east-1:123:PlanOfAttack')
    end

    it "returns the publisher" do
      expect(subject.register_channel(:aws_sns, :foo)).to eq(subject)
    end
  end

  describe "#register_destination" do
    before do
      subject.register_notification_service(:aws_sns)
    end

    it "registers the destination to be published to" do
      subject.register_destination(:sns_foo, :aws_sns, :foo, account: 123, region: "us-east-1", topic: "PlanOfAttack")
      result = subject.publishing_destination_registrar.fetch(:sns_foo)
      expect(result.service).to eq(:aws_sns)
      expect(result.channel).to eq(:foo)
    end

    it "returns the publisher" do
      result = subject.register_destination(
        :sns_foo,
        :aws_sns,
        :foo,
        account: 123,
        region: "us-east-1",
        topic: "PlanOfAttack"
      )
      expect(result).to eq(subject)
    end
  end

  describe "#publish" do
    let :notifier do
      subject.notification_service_registrar.fetch(:aws_sns).notifier
    end

    before do
      subject.register_notification_service(:file_system)
      subject.register_destination(:fs_foo, :file_system, :foo, path: "tmp/test_queue")
    end

    around do |ex|

      DispatchRider.config.debug = true
      ex.call
    ensure
      DispatchRider.config.debug = false

    end

    it "publishes the message to the notification service" do
      existing = Dir['tmp/test_queue/*']
      expect {
        subject.publish(destinations: [:fs_foo], message: { subject: "bar_handler", body: { "bar" => "baz" } })
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

        before { DispatchRider.config.callbacks.for(:publish) << publish_callback }

        after { DispatchRider.config.callbacks.for(:publish).delete publish_callback }

        example do
          expect(publish_callback).to receive(:call).with(
            an_instance_of(Proc), # first argument is the inner job
            { destinations: [:fs_foo], message: an_instance_of(DispatchRider::Message) }
          )
          publisher.publish(
            destinations: [:fs_foo],
            message: {
              subject: "bar_handler",
              body: { "bar" => "baz" }
            }
          )
        end
      end
    end
  end
end
