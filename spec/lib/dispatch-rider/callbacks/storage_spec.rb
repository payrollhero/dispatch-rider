require 'spec_helper'

describe DispatchRider::Callbacks::Storage do
  subject { described_class.new }

  describe "adding callbacks" do
    let!(:log) { [] }
    let(:actual) { proc { log << :actual } }

    describe "#around" do
      example do
        subject.around(:initialize) do |job|
          log << :abefore
          job.call
          log << :aafter
        end
        subject.for(:initialize).first[actual]
        expect(log).to eq %i[abefore actual aafter]
      end
    end

    describe "#before" do
      example do
        subject.before(:initialize) { log << :before }
        subject.for(:initialize).first[actual]
        expect(log).to eq %i[before actual]
      end
    end

    describe "#after" do
      example do
        subject.after(:initialize) { log << :after }
        subject.for(:initialize).first[actual]
        expect(log).to eq %i[actual after]
      end
    end
  end
end
