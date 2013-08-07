require 'spec_helper'

describe DispatchRider::Publisher::ConfigurationReader do

  let :publisher do
    double(:publisher)
  end

  describe ".parse" do

    subject { described_class }

    it "responds to :parse" do
      subject.should respond_to :parse
    end

    it "requires 2 paramaters" do
      expect {
        subject.parse
      }.to raise_exception(ArgumentError, /0 for 2/)
    end

    it "deals with an empty configuration hash" do
      expect {
        subject.parse({}, publisher)
      }.to_not raise_exception
    end

    describe "notification_services parsing" do

      context "when notification_services has no items in it" do

        let :configuration_hash do
          {
            notification_services: {
            }
          }
        end

        it "doesn't call register_notification_service" do
          publisher.should_not_receive(:register_notification_service)
          subject.parse(configuration_hash, publisher)
        end
      end

      context "when notification_services has an item in it" do
        let :configuration_hash do
          {
            notification_services: {
              file_system: {}
            }
          }
        end

        it "calls register_notification_service with :file_system and {}" do
          publisher.should_receive(:register_notification_service).with(:file_system, {})
          subject.parse(configuration_hash, publisher)
        end
      end

      context "when notification_services has 2 items in it" do
        let :configuration_hash do
          {
            notification_services: {
              file_system: {},
              foo: {bar: "123"},
            }
          }
        end

        it "calls register_notification_service with :file_system and {}, as well as :foo, {bar: '123'}" do
          publisher.should_receive(:register_notification_service).with(:file_system, {})
          publisher.should_receive(:register_notification_service).with(:foo, {bar: "123"})
          subject.parse(configuration_hash, publisher)
        end
      end

    end

    describe "destinations" do

      context "when destinations has no items in it" do

        let :configuration_hash do
          {
            destinations: {
            }
          }
        end

        it "doesn't call register_destination" do
          publisher.should_not_receive(:register_destination)
          subject.parse(configuration_hash, publisher)
        end

      end

      context "when destinations has items in it" do

        let :configuration_hash do
          {
            destinations: {
              out1:{
                service: :file_system,
                channel: :foo,
                options: {
                  path: "test/channel"
                }
              }
            }
          }
        end

        it "should call register_destination with the right parameters" do
          publisher.should_receive(:register_destination).exactly(1).times.with(:out1, :file_system, :foo, path: "test/channel")
          subject.parse(configuration_hash, publisher)
        end

      end

    end

  end # .parse

end
