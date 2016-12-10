class Ffmpeg
  class << self
    def run(options)
      `ffmpeg -loglevel warning -y #{options}`
    end
  end
end
