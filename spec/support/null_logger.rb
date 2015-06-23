class NullLogger
  def ignore(*_args)
  end

  alias info ignore
  alias error ignore
  alias debug ignore
  alias warn ignore
end
