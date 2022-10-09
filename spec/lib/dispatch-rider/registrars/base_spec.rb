# frozen_string_literal: true

require 'spec_helper'

describe DispatchRider::Registrars::Base do
  subject do
    described_class.new
  end

  describe "#initialize" do
    it "assigns store" do
      expect(subject.store).to be_empty
    end
  end

  describe "#register" do
    it "registers the value" do
      expect(subject).to receive(:value).with(:foo, {}).and_return("bar")
      subject.register(:foo)
      expect(subject.fetch(:foo)).to eq('bar')
    end

    it "should return the registrar" do
      expect(subject).to receive(:value).with(:foo, {}).and_return("bar")
      expect(subject.register(:foo)).to eq(subject)
    end

    context "when there is a missing constant while registering" do
      it "raises an exception" do
        expect(subject).to receive(:value).with(:foo, {}) { 'bar'.camelize.constantize }
        expect { subject.register(:foo) }.to raise_exception(DispatchRider::NotFound)
      end
    end
  end

  describe "#unregister" do
    before :each do
      allow(subject).to receive(:value).and_return('bar')
      subject.register(:foo)
    end

    it "unregisters the key/value pair from the registrar" do
      subject.unregister(:foo)
      expect { subject.fetch(:foo) }.to raise_exception(DispatchRider::NotRegistered)
    end

    it "returns the registrar" do
      expect(subject.unregister(:foo)).to eq(subject)
    end
  end

  describe "#fetch" do
    context "when a key/value pair is registered" do
      before :each do
        allow(subject).to receive(:value).and_return('bar')
        subject.register(:foo)
      end

      it "return the value for the key" do
        expect(subject.fetch(:foo)).to eq('bar')
      end
    end

    context "when a key/value pair is not registered" do
      it "raises an exception" do
        expect { subject.fetch(:foo) }.to raise_exception(DispatchRider::NotRegistered)
      end
    end
  end
end
