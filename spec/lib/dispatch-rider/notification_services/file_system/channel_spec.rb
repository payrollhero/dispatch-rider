# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem::Channel do
  let(:path) { File.expand_path("tmp/test/channel") }
  let(:published_message) { File.new(Dir["#{path}/*.ready"].first).read }

  before { FileUtils.mkdir_p(path) }
  after { FileUtils.rm_rf(path) }

  subject { described_class.new(path) }

  describe "#publish" do
    let(:message) { { subject: "foo", body: "bar" }.to_json }

    it "adds a file to the path folder" do
      expect {
        subject.publish(message: message)
      }.to change { Dir["#{path}/*"].length }.by(1)
    end

    it "writes the message to the file" do
      subject.publish(message: message)

      expect(published_message).to eq(message)
    end
  end
end
