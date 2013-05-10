require 'spec_helper'

describe DispatchRider::NotificationServices::FileSystem::Channel do

  let(:path) { File.expand_path("test/channel") }

  before do
    FileUtils.mkdir_p(path)
  end

  after do
    FileUtils.rm_rf(path)
  end

  subject { described_class.new(path) }

  describe "#publish" do
    it "adds a file to the path folder" do
      expect {
        subject.publish({:subject => "foo", :body => "bar"})
      }.to change { Dir["#{path}/*"].length }.by(1)
    end
  end

end
