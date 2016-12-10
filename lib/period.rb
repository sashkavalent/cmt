class Period
  class Position
    attr_reader :seconds

    def initialize(string_position)
      minutes, seconds = string_position.split(':').map(&:to_i)
      @seconds = minutes * 60 + seconds
    end

    def humanize
      '%d:%02d' % [@seconds / 60, @seconds % 60]
    end
  end

  attr_reader :start, :finish

  def initialize(string_period)
    @start, @finish = string_period.split('-').map { |pos| Position.new(pos) }
  end

  def duration
    finish.seconds - start.seconds
  end

  def humanize
    "#{@start.humanize}-#{@finish.humanize}"
  end

  alias_method :to_s, :humanize
end
