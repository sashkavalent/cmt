require 'fileutils'
require 'uri'

file_path = ARGV[0]
time_periods = ARGV[1..-1]
delete_audio_file = false

if file_path =~ URI::regexp
  puts "Analyzing video source..."

  available_formats = `youtube-dl -F #{file_path}`
  target_format = available_formats.split("\n").grep(/\s*m4a\s*/).first.split.first

  puts "Downloading #{target_format} m4a audio file..."

  download_log = `youtube-dl -f #{target_format} #{file_path}`
  file_destination_marker = '[download] Destination: '
  file_destination_log = download_log.split("\n").find { |s| s.start_with?(file_destination_marker) }
  audio_file_path =
    if file_destination_log
      file_destination_log.gsub(file_destination_marker, '')
    else
      file_downloaded_marker = ' has already been downloaded'
      file_downloaded_log = download_log.split("\n").find { |s| s.end_with?(file_downloaded_marker) }
      file_downloaded_log.gsub(file_downloaded_marker, '').gsub('[download] ', '')
    end

  new_audio_file_path = audio_file_path + '.mp3'

  puts 'Converting m4a to mp3...'

  `ffmpeg -v 5 -y -i '#{audio_file_path}' -acodec libmp3lame -ac 2 -ab 192k '#{new_audio_file_path}'`
  FileUtils.rm(audio_file_path)
  delete_audio_file = true
  audio_file_path = new_audio_file_path
end

audio_file_path ||= file_path

periods_and_coolness = time_periods.map do |period|
  puts "Analyzing #{period} period"

  start, ent = period.split('-')
  file_name = "#{audio_file_path}_#{period}.mp3"
  `sox '#{audio_file_path}' '#{file_name}' trim #{start} '=#{ent}'`

  stat = `sox '#{file_name}' -n stat 2>&1`
  FileUtils.rm(file_name)

  mean_norm = stat.split("\n").grep(/\AMean\s*norm/).first.split.last.to_f
  [period, mean_norm]
end
FileUtils.rm(audio_file_path) if delete_audio_file

puts "    period      coolness"
periods_and_coolness.sort_by { |_period, coolness| -coolness }.each_with_index do |(period, coolness), index|
  puts "#{index + 1}   #{period}   #{(coolness * 1_000).round}"
end
