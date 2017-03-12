require 'shellwords'

class Ffmpeg
  class << self
    def crop(path, output_path, start, duration)
      path = Shellwords.escape(path)
      output_path = Shellwords.escape(output_path)
      run("-i #{path} -ss #{start} -c copy -t #{duration} #{output_path}")
    end

    def run(options)
      System.run("ffmpeg -loglevel warning -y #{options}")
    end
  end
end
