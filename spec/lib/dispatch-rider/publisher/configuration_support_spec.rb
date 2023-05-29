# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Publisher::ConfigurationSupport do
  subject { Object.new.extend(described_class) }

  describe ".configuration" do
    example do
      expect(subject.configuration).to be_a(DispatchRider::Publisher::Configuration)
    end
  end

  describe ".config" do
    example do
      expect(subject.method(:config)).to eq(subject.method(:configuration))
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
      before do
        subject.configure(configuration_hash)
      end

      it "sets the configuration's notification services correctly" do
        expect(subject.configuration.notification_services.count).to eq(1)
        expect(subject.configuration.notification_services).to match_array([notification_service])
      end

      it "sets the configuration's destinations correctly" do
        expect(subject.configuration.destinations.count).to eq(1)
        expect(subject.configuration.destinations).to match_array([destination])
      end
    end

    context "when configuring with a block" do
      before do
        subject.configure do |config|
          config.parse(configuration_hash)
        end
      end

      it "sets the configuration's notification services correctly" do
        expect(subject.configuration.notification_services.count).to eq(1)
        expect(subject.configuration.notification_services).to match_array([notification_service])
      end

      it "sets the configuration's destinations correctly" do
        expect(subject.configuration.destinations.count).to eq(1)
        expect(subject.configuration.destinations).to match_array([destination])
      end
    end
  end
end
