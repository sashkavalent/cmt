require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'pry'
  gem 'rest-client'
  gem 'activesupport'
end

require 'active_support'
require 'active_support/core_ext'

require_relative 'lib/utils/log'
require_relative 'lib/utils/keys'
require_relative 'lib/utils/ffmpeg'
require_relative 'lib/video'

video = Video.new(ARGV[0], ARGV[1..-1]).tap(&:process)
1_000.times do
  break if video.processed?
  sleep 4.minutes
end

p video.periods_and_coolness

headers = %w(# period coolness happiness noise)
format = "%-3s %-12s %-10s %-10s %-10s\n"
printf(format, *headers)
video.periods_and_coolness.each_with_index do |params, index|
  printf(format, index + 1, *params)
end
