require_relative 'video_part'
require_relative 'period'

class VideoSplitter
  def initialize(path, periods)
    @path, @periods = path, periods
    @periods = @periods.split(' ') if @periods.is_a?(String)
  end

  def split
    @video_parts = @periods.sort.map { |per| Period.new(per) }.map do |period|
      file_name = "#{@path}_#{period}.mp4"
      Ffmpeg.run("-i '#{@path}' -ss #{period.start.seconds} -c copy -t #{period.duration} '#{file_name}'")
      Log.logger.info("Saved '#{file_name}'")
      VideoPart.new(period, file_name)
    end
  end
end
