require 'fileutils'
require 'shellwords'

class NoiseRecognizer
  attr_reader :noise_level

  def initialize(video_part)
    @video_part = video_part
  end

  def process
    mp3_file = "#{@video_part.path}.mp3"
    Ffmpeg.run("-i #{Shellwords.escape(@video_part.path)} -vn #{Shellwords.escape(mp3_file)}")
    sox_stats = System.run("sox #{Shellwords.escape(mp3_file)} -n stat")

    @noise_level = sox_stats.split("\n").grep(/\AMean\s*norm/).first.split.last.to_f
    FileUtils.rm(mp3_file)
    Log.logger.info("Noise processing #{@video_part.period} finished")
    @noise_level
  end
end
