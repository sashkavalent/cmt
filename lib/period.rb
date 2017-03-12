class Period
  class Position
    attr_accessor :seconds

    def initialize(string_position)
      numbers = string_position.split(':').map(&:to_i)
      @seconds = numbers.reverse.each_with_index.inject(0) { |sum, (number, index)| sum + number * (60**index) }
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

  def trim_by(seconds)
    @finish.seconds -= seconds
  end
end
