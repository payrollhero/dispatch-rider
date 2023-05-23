# frozen_string_literal: true

require "spec_helper"

describe DispatchRider::ScheduledJob do
  let(:message_details) {
    {
      destinations: ["allied_forces"],
      message: {
        "subject" => "war_update",
        "body" => { "enigma_machine" => "broken" }
      }
    }
  }

  let!(:due_job) { described_class.create! message_details.merge(scheduled_at: 1.minute.ago) }
  let!(:later_job) { described_class.create! message_details.merge(scheduled_at: 30.minutes.since) }

  describe ".due" do
    describe "due now" do
      subject(:due_jobs) { described_class.due }

      it { expect(due_jobs).to include due_job }
      it { expect(due_jobs).to_not include later_job }
    end

    describe "due tomorrow" do
      subject(:due_jobs) { described_class.due Date.tomorrow.midnight }

      it { expect(due_jobs).to include due_job }
      it { expect(due_jobs).to include later_job }
    end
  end

  describe ".publish_due_jobs" do
    example {
      expect(described_class.publisher).to receive(:publish).once.with destinations: ["allied_forces"],
                                                                       message: {
                                                                         "subject" => "war_update",
                                                                         "body" => { "enigma_machine" => "broken" }
                                                                       }

      2.times { described_class.publish_due_jobs }
    }
  end

  describe "#destinations serialization" do
    subject { described_class.find(due_job.id).destinations }

    it { is_expected.to eq ["allied_forces"] }
  end

  describe "#message serialization" do
    subject { described_class.find(due_job.id).message }

    it {
      expect(subject).to eq "subject" => "war_update",
                            "body" => { "enigma_machine" => "broken" }
    }
  end

  describe "#publish" do
    subject(:job) { described_class.find(due_job.id) }

    example {
      expect(described_class.publisher).to receive(:publish).with destinations: ["allied_forces"],
                                                                  message: {
                                                                    "subject" => "war_update",
                                                                    "body" => { "enigma_machine" => "broken" }
                                                                  }

      job.publish
    }
  end
end
