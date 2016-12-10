require 'fileutils'

class NoiseRecognizer
  attr_reader :noise_level

  def initialize(video_part)
    @video_part = video_part
  end

  def process
    mp3_file = "#{@video_part.path}.mp3"
    Ffmpeg.run("-i '#{@video_part.path}' -vn '#{mp3_file}'")
    stat = `sox '#{mp3_file}' -n stat 2>&1`
    @noise_level = stat.split("\n").grep(/\AMean\s*norm/).first.split.last.to_f
    FileUtils.rm(mp3_file)
    Log.logger.info("Noise processing #{@video_part.period} finished")
    @noise_level
  end
end
