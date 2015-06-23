class CrashingHandler < DispatchRider::Handlers::Base
  def process(params)
    raise "I crashed!"
  end
end
