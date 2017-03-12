require_relative 'video_splitter'
require_relative 'coolness_normalizer'
require_relative 'video_downloader'

class Video
  def initialize(path, periods)
    @path = VideoDownloader.new(path).run
    @video_parts = VideoSplitter.new(@path, periods).split
  end

  def process
    @video_parts.each(&:process)
  end

  def processed?
    @video_parts.all?(&:processed?)
  end

  def periods_and_coolness
    return unless processed?
    CoolnessNormalizer.new(@video_parts).normalize!

    @video_parts.sort_by { |vp| -vp.coolness }.map do |part|
      [part.period.to_s, part.coolness, part.normalized_happiness_level, part.normalized_noise_level]
    end
  end
end
