class Timer
  def initialize
    @ms_offset = Gosu.milliseconds
  end

  def frame(div, num)
    ((Gosu.milliseconds - @ms_offset) >> div) % num
  end

  def time
    Gosu.milliseconds - @ms_offset
  end

  def reset
    @ms_offset = Gosu.milliseconds
  end
end
