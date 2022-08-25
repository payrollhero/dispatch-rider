require 'spec_helper'

describe DispatchRider::Publisher::Base do

  class DummyPublisher < DispatchRider::Publisher::Base
    destinations %i[sns_message_queue file_system_queue]
    subject "Loud Cheering"

    def self.publish(cheer)
      new.publish(cheer)
    end
  end

  class DummyCustomPublisher < DispatchRider::Publisher::Base
    destinations :sqs_message_queue
    subject "Ferocious Tigers!"

    def self.publish(body, publisher)
      new(publisher).publish(body)
    end
  end

  describe ".default_publisher" do
    example do
      expect(described_class.default_publisher).to be_a(DispatchRider::Publisher)
    end
  end

  describe ".publish" do
    context "in the base class" do
      example do
        expect {
          described_class.publish
        }.to raise_error NotImplementedError
      end
    end

    context "in a derived class with publish implemented" do
      let(:message) do
        {
          destinations: %i[sns_message_queue file_system_queue],
          message: {
            subject: "Loud Cheering",
            body: {
              "bla" => "WOOOOOOOO!",
            }
          }
        }
      end

      example do
        expect(DummyPublisher.default_publisher).to receive(:publish).with(message)
        DummyPublisher.publish "bla" => "WOOOOOOOO!"
      end
    end

    context "in a derived class with publish implemented and a custom publisher" do
      let(:message) do
        {
          destinations: [:sqs_message_queue],
          message: {
            subject: "Ferocious Tigers!",
            body: {
              "bla" => "RAAAAAWWWWW!",
            },
          }
        }
      end

      let(:publisher) { double(:publisher) }

      example do
        expect(publisher).to receive(:publish).with(message)
        DummyCustomPublisher.publish({"bla" => "RAAAAAWWWWW!"}, publisher)
      end
    end
  end

end
