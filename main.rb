require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
Bundler.require(:development)

require_relative 'lib/utils/log'
require_relative 'lib/utils/keys'
require_relative 'lib/utils/ffmpeg'
require_relative 'lib/utils/system'
require_relative 'lib/utils/color'
require_relative 'lib/video'

video = Video.new(ARGV[0], ARGV[1..-1]).tap(&:process)
1_000.times do
  break if video.processed?
  interval = 4.minutes
  Log.logger.info("Waiting for emotion recognition processing. Sleep for #{interval.inspect}")
  sleep interval
end

p video.periods_and_coolness

headers = %w(# period coolness happiness noise)
format = "%-3s %-12s %-10s %-10s %-10s\n"
printf(format, *headers)
video.periods_and_coolness.each_with_index do |params, index|
  printf(format, index + 1, *params)
end
