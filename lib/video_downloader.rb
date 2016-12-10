class VideoDownloader
  def initialize(path_or_url)
    @path_or_url = path_or_url
  end

  def run
    if @path_or_url =~ URI.regexp
      file_path = 'video/%(title)s-%(id)s.%(ext)s'
      download_command = "youtube-dl '#{@path_or_url}' -o '#{file_path}'"
      full_file_path = `#{download_command} --get-filename`.strip
      `#{download_command}`
      Log.logger.info("Downloaded video to '#{full_file_path}'")
      full_file_path
    else
      @path_or_url
    end
  end
end
