# frozen_string_literal: true

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

  subject { described_class.new("employee", attributes) }

  describe "#name" do
    describe '#name' do
      subject { super().name }
      it { is_expected.to eq("employee") }
    end
  end

  describe "#service" do
    describe '#service' do
      subject { super().service }
      it { is_expected.to eq("aws_sns") }
    end
  end

  describe "#channel" do
    describe '#channel' do
      subject { super().channel }
      it { is_expected.to eq("employee_updates") }
    end
  end

  describe "#options" do
    describe '#options' do
      subject { super().options }
      it { is_expected.to eq(options) }
    end
  end

  describe "#==" do
    let(:other) { described_class.new(name, other_attributes) }

    context "when the destinations' name, service, channel and options are the same" do
      let(:name) { subject.name }
      let(:other_attributes) { attributes }

      it { is_expected.to eq other }
    end

    context "when the destinations' name is different" do
      let(:name) { "account" }
      let(:other_attributes) { attributes }

      it { is_expected.not_to eq other }
    end

    context "when the destinations' service is different" do
      let(:name) { subject.name }

      let(:other_attributes) do
        {
          "service" => "file_system",
          "channel" => "employee_updates",
          "options" => options
        }
      end

      it { is_expected.not_to eq other }
    end

    context "when the destinations' channel is different" do
      let(:name) { subject.name }

      let(:other_attributes) do
        {
          "service" => "aws_sns",
          "channel" => "account_updates",
          "options" => options
        }
      end

      it { is_expected.not_to eq other }
    end

    context "when the destinations' options are different" do
      let(:name) { subject.name }

      let(:other_attributes) do
        {
          "service" => "aws_sns",
          "channel" => "employee_updates",
          "options" => {}
        }
      end

      it { is_expected.not_to eq other }
    end
  end
end
