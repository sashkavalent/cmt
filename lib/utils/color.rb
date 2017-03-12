class Color
  class << self
    def red(string)
      colorize(string, 31)
    end

    def green(string)
      colorize(string, 32)
    end

    def yellow(string)
      colorize(string, 33)
    end

    def blue(string)
      colorize(string, 34)
    end

    def pink(string)
      colorize(string, 35)
    end

    def light_blue(string)
      colorize(string, 36)
    end

    def colorize(string, color_code)
      "\e[#{color_code}m#{string}\e[0m"
    end
  end
end
