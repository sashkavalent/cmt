require_relative 'emotion_recognizer'
require_relative 'noise_recognizer'

class VideoPart
  delegate :happiness_level, to: :@emotion_detector
  delegate :noise_level, to: :@noise_detector

  attr_reader :period, :path
  attr_accessor :coolness, :normalized_happiness_level, :normalized_noise_level

  def initialize(period, path)
    @period, @path = period, path
    @emotion_detector = EmotionRecognizer.new(self)
    @noise_detector = NoiseRecognizer.new(self)
  end

  def process
    @emotion_detector.start_processing
    @noise_detector.process
  end

  def processed?
    !!(noise_level && happiness_level)
  end
end
