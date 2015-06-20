require 'spec_helper'

describe DispatchRider::Registrars::FileSystemChannel do
  describe "#value" do
    let(:path){ "/foo/bar" }
    let(:channel_options){ {path: path} }

    it "returns the expanded path from the options" do
      expect(subject.value(:foo, channel_options)).to eq("/foo/bar")
    end
  end
end
