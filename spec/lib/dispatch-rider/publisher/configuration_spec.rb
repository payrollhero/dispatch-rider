require 'spec_helper'

describe DispatchRider::Publisher::Configuration do

  let(:configuration_hash) do
    {
      "notification_services" => {
        "file_system" => {
          "default_folder" => "tmp/dispatch_rider"
        },
        "aws_sns" => {}
      },
      "destinations" => {
        "employee_updates" => {
          "service" => "file_system",
          "channel" => "employee_updates",
          "options" => {
            "file_prefix" => "employee_"
          }
        },
        "account_updates" => {
          "service" => "aws_sns",
          "channel" => "account_updates",
          "options" => {
            "account" => "123456789",
            "region" => "us-east",
            "topic" => "account-updates"
          }
        }
      }
    }
  end

  subject { described_class.new(configuration_hash) }

  describe "#notification services" do
    let(:file_system) do
      DispatchRider::Publisher::Configuration::NotificationService.new(
        "file_system",
        "default_folder" => "tmp/dispatch_rider"
      )
    end

    let(:sns) do
      DispatchRider::Publisher::Configuration::NotificationService.new("aws_sns", {})
    end

    it "contains both notification services" do
      expect(subject.notification_services.count).to eq(2)
      expect(subject.notification_services).to match_array([file_system, sns])
    end
  end

  describe "#destinations" do
    let(:employee_updates) do
      DispatchRider::Publisher::Configuration::Destination.new(
        "employee_updates",
        {
          "service" => "file_system",
          "channel" => "employee_updates",
          "options" => {
            "file_prefix" => "employee_"
          }
        }
      )
    end

    let(:account_updates) do
      DispatchRider::Publisher::Configuration::Destination.new(
        "account_updates",
        {
          "service" => "aws_sns",
          "channel" => "account_updates",
          "options" => {
            "account" => "123456789",
            "region" => "us-east",
            "topic" => "account-updates"
          }
        }
      )
    end

    it "contains both destinations" do
      expect(subject.destinations.count).to eq(2)
      expect(subject.destinations).to match_array([employee_updates, account_updates])
    end
  end

  describe "#clear" do
    example do
      expect {
        subject.clear
      }.to change(subject.notification_services, :count).by(-2)
    end

    example do
      expect {
        subject.clear
      }.to change(subject.destinations, :count).by(-2)
    end
  end

  describe "#parse" do
    let(:new_configuration_hash) do
      {
        "notification_services" => {
          "aws_sqs" => {}
        },
        "destinations" => {
          "user_deletion" => {
            "service" => "aws_sqs",
            "channel" => "user_deletion",
            "options" => {}
          }
        }
      }
    end

    let(:notification_service) do
      DispatchRider::Publisher::Configuration::NotificationService.new("aws_sqs", {})
    end

    let(:destination) do
      DispatchRider::Publisher::Configuration::Destination.new(
        "user_deletion",
        {
          "service" => "aws_sqs",
          "channel" => "user_deletion",
          "options" => {}
        }
      )
    end

    before :each do
      subject.parse(new_configuration_hash)
    end

    it "replaces the current notification services with the new notification service" do
      expect(subject.notification_services.count).to eq(1)
      expect(subject.notification_services).to match_array([notification_service])
    end

    it "replaces the current destinations with the new destination" do
      expect(subject.destinations.count).to eq(1)
      expect(subject.destinations).to match_array([destination])
    end
  end

end
