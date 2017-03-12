require_relative 'video_part'
require_relative 'period'

class VideoSplitter
  def initialize(path, periods)
    @path, @periods = path, periods
    @periods = @periods.split(' ') if @periods.is_a?(String)
  end

  def split
    @video_parts = @periods.sort.map do |per|
      period = Period.new(per)

      file_name = check_max_allowed_size_and_save!(period)
      Log.logger.info("Saved '#{file_name}'")
      VideoPart.new(period, file_name)
    end
  end

  private

  def check_max_allowed_size_and_save!(period)
    loop do
      file_name = @path.gsub(VideoDownloader::ORIGINAL_VIDEO_POSTFIX, '').gsub(/(\.\w+)\z/, "_#{period}" + '.mp4')

      Ffmpeg.crop(@path, file_name, period.start.seconds, period.duration)
      if File.size(file_name) > EmotionRecognizer::MAX_ALLOWED_FILE_SIZE
        old_period = period.to_s
        period.trim_by(5)
        Log.logger.warn("Cropping #{old_period} to #{period} as its size is too big for Microsoft recognition api")
      else
        break file_name
      end
    end
  end
end
