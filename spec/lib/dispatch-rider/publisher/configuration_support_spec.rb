require 'spec_helper'

describe DispatchRider::Publisher::ConfigurationSupport do

  subject{ Object.new.extend(described_class) }

  describe ".configuration" do
    example do
      subject.configuration.should be_a(DispatchRider::Publisher::Configuration)
    end
  end

  describe ".config" do
    example do
      subject.method(:config).should == subject.method(:configuration)
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
        subject.configure(configuration_hash)
      end

      it "sets the configuration's notification services correctly" do
        subject.configuration.notification_services.count.should == 1
        subject.configuration.notification_services.should =~ [notification_service]
      end

      it "sets the configuration's destinations correctly" do
        subject.configuration.destinations.count.should == 1
        subject.configuration.destinations.should =~ [destination]
      end
    end

    context "when configuring with a block" do
      before :each do
        subject.configure do |config|
          config.parse(configuration_hash)
        end
      end

      it "sets the configuration's notification services correctly" do
        subject.configuration.notification_services.count.should == 1
        subject.configuration.notification_services.should =~ [notification_service]
      end

      it "sets the configuration's destinations correctly" do
        subject.configuration.destinations.count.should == 1
        subject.configuration.destinations.should =~ [destination]
      end
    end
  end

end
