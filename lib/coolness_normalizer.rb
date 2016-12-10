class CoolnessNormalizer
  COOL_MULTIPLIER = 1_000
  VALUES_NAMES = [:happiness_level, :noise_level].freeze

  def initialize(video_parts)
    @video_parts = video_parts
  end

  def normalize!
    VALUES_NAMES.each { |value_name| normalize_value(value_name) }
    @video_parts.each do |vp|
      sum = VALUES_NAMES.map { |vn| vp.public_send("normalized_#{vn}") }.sum
      vp.coolness = sum / VALUES_NAMES.length
    end
  end

  private

  def normalize_value(value_name)
    all_values = @video_parts.map { |vp| vp.public_send(value_name).to_f }
    min_value, max_value = all_values.min, all_values.max
    diff = max_value - min_value

    @video_parts.each do |vp|
      value = diff.zero? ? 0 : ((vp.public_send(value_name) - min_value) / diff)
      vp.public_send("normalized_#{value_name}=", (value * COOL_MULTIPLIER).round)
    end
  end
end
