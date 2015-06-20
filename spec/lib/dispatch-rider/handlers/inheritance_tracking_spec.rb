require 'spec_helper'

describe DispatchRider::Handlers::InheritanceTracking do

  class InheritanceDummyClass
    extend DispatchRider::Handlers::InheritanceTracking
  end

  describe ".subclasses" do
    context "when a class inherits from the dummy class" do
      class Blah < InheritanceDummyClass; end

      example do
        expect(InheritanceDummyClass.subclasses).to include(Blah)
      end

      context "and another class inherits from the dummy class" do
        class Foo < InheritanceDummyClass; end

        example do
          expect(InheritanceDummyClass.subclasses).to include(Blah, Foo)
        end
      end
    end
  end

end
