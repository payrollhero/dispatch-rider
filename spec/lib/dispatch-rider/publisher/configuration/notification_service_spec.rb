require 'spec_helper'

describe DispatchRider::Publisher::Configuration::NotificationService do

  let(:options) do
    {
      "default_folder" => "/tmp/dispatch_rider"
    }
  end

  subject{ described_class.new("file_system", options) }

  describe "#name" do
    its(:name){ should == "file_system" }
  end

  describe "#options" do
    its(:options){ should == options }
  end

  describe "#==" do
    let(:other){ described_class.new(name, other_options) }

    context "two notification services with the same name and options" do
      let(:name){ subject.name }
      let(:other_options){ options }

      it{ should eq other }
    end

    context "two notification services with different names but the same options" do
      let(:name){ "aws_sns" }
      let(:other_options){ options }

      it{ should_not eq other }
    end

    context "two notificaiton services with the same name but different options" do
      let(:name){ subject.name }
      let(:other_options){ { "topic" => "employee_updates" } }

      it{ should_not eq other }
    end

    context "two notification services with different names and options" do
      let(:name){ "aws_sns" }
      let(:other_options){ { "topic" => "employee_updates" } }

      it{ should_not eq other }
    end
  end

end
