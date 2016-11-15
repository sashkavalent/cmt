require 'fileutils'

audio_file = ARGV[0]
time_periods = ARGV[1..-1]
periods_and_coolness = time_periods.map do |period|
  start, ent = period.split('-')
  file_name = "#{audio_file}_#{period}.mp3"
  `sox '#{audio_file}' '#{file_name}' trim #{start} '=#{ent}'`

  stat = `sox '#{file_name}' -n stat 2>&1`
  FileUtils.rm(file_name)

  mean_norm = stat.split("\n").grep(/\AMean\s*norm/).first.split.last.to_f
  [period, mean_norm]
end

puts "    period      coolness"
periods_and_coolness.sort_by { |_period, coolness| -coolness }.each_with_index do |(period, coolness), index|
  puts "#{index + 1}   #{period}   #{(coolness * 1_000).round}"
end
