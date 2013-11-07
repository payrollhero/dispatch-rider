require 'spec_helper'

describe DispatchRider::Publisher::Configuration::Destination do

  let(:attributes) do
    {
      "service" => "aws_sns",
      "channel" => "employee_updates",
      "options" => options
    }
  end

  let(:options) do
    {
      "account" => "123456789",
      "region" => "us-east",
      "topic" => "employee-updates"
    }
  end

  subject{ described_class.new("employee", attributes) }

  describe "#name" do
    its(:name){ should == "employee" }
  end

  describe "#service" do
    its(:service){ should == "aws_sns" }
  end

  describe "#channel" do
    its(:channel){ should == "employee_updates" }
  end

  describe "#options" do
    its(:options){ should == options }
  end

  describe "#==" do
    let(:other){ described_class.new(name, other_attributes) }

    context "when the destinations' name, service, channel and options are the same" do
      let(:name){ subject.name }
      let(:other_attributes){ attributes }

      it{ should eq other }
    end

    context "when the destinations' name is different" do
      let(:name){ "account" }
      let(:other_attributes){ attributes }

      it{ should_not eq other }
    end

    context "when the destinations' service is different" do
      let(:name){ subject.name }

      let(:other_attributes) do
        {
          "service" => "file_system",
          "channel" => "employee_updates",
          "options" => options
        }
      end

      it{ should_not eq other }
    end

    context "when the destinations' channel is different" do
      let(:name){ subject.name }

      let(:other_attributes) do
        {
          "service" => "aws_sns",
          "channel" => "account_updates",
          "options" => options
        }
      end

      it{ should_not eq other }
    end

    context "when the destinations' options are different" do
      let(:name){ subject.name }

      let(:other_attributes) do
        {
          "service" => "aws_sns",
          "channel" => "employee_updates",
          "options" => {}
        }
      end

      it{ should_not eq other }
    end
  end

end
