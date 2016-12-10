# docs here https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/56f8d40e1984551ec0a0984e

require 'json'
require 'rest-client'
require_relative 'operation_location_storage'

class EmotionRecognizer
  URL = 'https://api.projectoxford.ai/emotion/v1.0/recognizeInVideo'.freeze
  RATE_LIMIT_SLEEP = 1.minute

  def initialize(video_part)
    @video_part = video_part
  end

  def start_processing
    @operation_location = OperationLocationStorage.find(@video_part) || upload_file

    Log.logger.info("Emotion recognition. Operation location for #{@video_part.period} is #{@operation_location}")
  end

  def happiness_level
    @average_happiness ||= check_status
  end

  private

  def upload_file
    res = request do
      RestClient::Request.execute(method: :post, url: URL, payload: File.new(@video_part.path),
                                  headers: { content_type: 'application/octet-stream' }.merge(key_header))
    end
    Log.logger.info("Emotion recognition. Uploaded #{@video_part.period} for processing")

    OperationLocationStorage.create(@video_part, res.headers[:operation_location])
    res.headers[:operation_location]
  end

  def check_status
    return @average_happiness if @average_happiness

    check_response = request do
      JSON.parse(RestClient.get(@operation_location, key_header))
    end

    case check_response['status']
    when 'Succeeded'
      process_result(check_response['processingResult'])
      Log.logger.info("Emotion recognition. Processing #{@video_part.period} successfully finished")
    when 'Running'
      Log.logger.info("Emotion recognition. Processing #{@video_part.period}, progress is #{check_response['progress']}%")
    when 'Failed'
      Log.logger.error("Emotion recognition. Processing #{@video_part.period} failed with #{check_response}. Reuploading")
      upload
    end
    @average_happiness
  end

  def request(&block)
    begin
      yield
    rescue RestClient::ExceptionWithResponse => e
      case e.response.code
      when 429
        Log.logger.info("Emotion recognition. Rate limit is exceeded. Sleep for #{RATE_LIMIT_SLEEP} seconds")
        sleep RATE_LIMIT_SLEEP
        retry
      else
        Log.logger.error(e.response.body)
        raise e
      end
    end
  end

  # {
  #   "version": 1,
  #   "timescale": 90000,
  #   "offset": 0,
  #   "framerate": 30,
  #   "width": 1280,
  #   "height": 720,
  #   "fragments": [
  #     {
  #       "start": 0,
  #       "duration": 180000,
  #       "interval": 45000,
  #       "events": [
  #         [
  #           {
  #             "windowFaceDistribution": {
  #               "neutral": 0.666667, "happiness": 0.333333, "surprise": 0, "sadness": 0, "anger": 0,
  #               "disgust": 0, "fear": 0, "contempt": 0
  #             },
  #             "windowMeanScores": {
  #               "neutral": 0.572126, "happiness": 0.420142, "surprise": 0.00194386, "sadness": 0.00256541,
  #               "anger": 0.000470987, "disgust": 0.000268275, "fear": 0.0000517474, "contempt": 0.00243189
  #             }
  #           }
  #         ],
  #         []
  #       ]
  #     },
  #     {}
  #   ]
  # }
  #
  def process_result(response)
    events = JSON.parse(response)['fragments'].flat_map { |f| f['events'] }.reject(&:blank?)
    @average_happiness = events.sum { |e| e.first['windowMeanScores']['happiness'] } / events.length
  end

  def key_header
    @key_header ||= { 'Ocp-Apim-Subscription-Key' => Keys.fetch(:microsoft, :emotion_api_key) }
  end
end
