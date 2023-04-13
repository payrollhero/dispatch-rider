# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Publisher::Configuration::NotificationService do

  subject { described_class.new("file_system", options) }

  let(:options) do
    {
      "default_folder" => "/tmp/dispatch_rider"
    }
  end

  describe "#name" do
    describe '#name' do
      subject { super().name }

      it { is_expected.to eq("file_system") }
    end
  end

  describe "#options" do
    describe '#options' do
      subject { super().options }

      it { is_expected.to eq(options) }
    end
  end

  describe "#==" do
    let(:other) { described_class.new(name, other_options) }

    context "two notification services with the same name and options" do
      let(:name) { subject.name }
      let(:other_options) { options }

      it { is_expected.to eq other }
    end

    context "two notification services with different names but the same options" do
      let(:name) { "aws_sns" }
      let(:other_options) { options }

      it { is_expected.not_to eq other }
    end

    context "two notificaiton services with the same name but different options" do
      let(:name) { subject.name }
      let(:other_options) { { "topic" => "employee_updates" } }

      it { is_expected.not_to eq other }
    end

    context "two notification services with different names and options" do
      let(:name) { "aws_sns" }
      let(:other_options) { { "topic" => "employee_updates" } }

      it { is_expected.not_to eq other }
    end
  end

end
