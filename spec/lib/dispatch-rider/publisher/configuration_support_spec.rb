require 'spec_helper'

describe DispatchRider::Publisher::ConfigurationSupport do

  class DummyPublisherClass
    include DispatchRider::Publisher::ConfigurationSupport
  end

  subject{ DummyPublisherClass.new }

  describe ".configuration" do
    example do
      DummyPublisherClass.configuration.should be_a(DispatchRider::Publisher::Configuration)
    end
  end

  describe ".config" do
    example do
      DummyPublisherClass.method(:config).should ==DummyPublisherClass.method(:configuration)
    end
  end

  describe ".configure" do
    let :configuration_hash do
      {
        notification_services: {
          file_system: {}
        },
        destinations: {
          file_foo: {
            service: :file_system,
            channel: :foo,
            options: {
              path: "tmp/test/channel",
            }
          }
        }
      }
    end

    let(:notification_service) do
      DispatchRider::Publisher::Configuration::NotificationService.new("file_system", {})
    end

    let(:destination) do
      DispatchRider::Publisher::Configuration::Destination.new(
        "file_foo",
        {
          service: :file_system,
          channel: :foo,
          options: {
            path: "tmp/test/channel"
          }
        }
      )
    end

    context "when configuring with a hash" do
      before :each do
        DummyPublisherClass.configure(configuration_hash)
      end

      it "sets the configuration's notification services correctly" do
        DummyPublisherClass.configuration.notification_services.count.should == 1
        DummyPublisherClass.configuration.notification_services.should =~ [notification_service]
      end

      it "sets the configuration's destinations correctly" do
        DummyPublisherClass.configuration.destinations.count.should == 1
        DummyPublisherClass.configuration.destinations.should =~ [destination]
      end
    end

    context "when configuring with a block" do
      before :each do
        DummyPublisherClass.configure do |config|
          config.parse(configuration_hash)
        end
      end

      it "sets the configuration's notification services correctly" do
        DummyPublisherClass.configuration.notification_services.count.should == 1
        DummyPublisherClass.configuration.notification_services.should =~ [notification_service]
      end

      it "sets the configuration's destinations correctly" do
        DummyPublisherClass.configuration.destinations.count.should == 1
        DummyPublisherClass.configuration.destinations.should =~ [destination]
      end
    end
  end

  describe "#configure" do

    let (:configuration){ DispatchRider::Publisher::Configuration.new }

    it "calls config reader" do
      DispatchRider::Publisher::ConfigurationReader.should_receive(:load_config).with(configuration, subject)
      subject.configure(configuration)
    end
  end
end
