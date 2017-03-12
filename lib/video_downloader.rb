require 'fileutils'
require 'shellwords'

class VideoDownloader
  DIRECTORY = 'video'.freeze
  ORIGINAL_VIDEO_POSTFIX = '_original'.freeze

  def initialize(path_or_url)
    @path_or_url = path_or_url
  end

  def run
    if @path_or_url =~ URI.regexp
      youtube_id = @path_or_url.match(/\?v\=(.+)\z/).captures.first
      file_name = find_existing_video(youtube_id)

      if file_name
        Log.logger.info("Using previously downloaded video '#{file_name}'")
      else
        Log.logger.info("Downloading video from '#{@path_or_url}'")
        output = "#{DIRECTORY}/%(title)s-%(id)s#{ORIGINAL_VIDEO_POSTFIX}.%(ext)s"
        path = Shellwords.escape(@path_or_url)
        System.run("youtube-dl #{path} -o '#{output}' -f 'bestvideo[ext=mp4]+bestaudio' --merge-output-format mp4")
        file_name = find_existing_video(youtube_id)
        Log.logger.info("Downloaded video to '#{file_name}'")
      end

      file_name
    else
      @path_or_url
    end
  end

  private

  def find_existing_video(youtube_id)
    youtube_id = Regexp.quote(youtube_id)
    Dir.glob("#{DIRECTORY}/*#{youtube_id}#{ORIGINAL_VIDEO_POSTFIX}*").first
  end
end
