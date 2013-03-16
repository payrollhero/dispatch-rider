require 'spec_helper'

describe DispatchRider::Message, :nodb => true do

    # ===============
    # = Validations =
    # ===============
    it { should validate_presence_of(:subject) }  # subject tells what should be done
    it { should_not validate_presence_of(:body) } # it's not all the time that you would need a body

end
