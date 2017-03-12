# docs here https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/56f8d40e1984551ec0a0984e
# pricing https://azure.microsoft.com/en-us/services/cognitive-services/emotion/

require 'json'
require 'rest-client'
require_relative 'operation_location_storage'

class EmotionRecognizer
  MAX_ALLOWED_FILE_SIZE = 100_000_000 # real max allowed video size is not 100MB, but 100 million bytes
  URL = 'https://westus.api.cognitive.microsoft.com/emotion/v1.0/recognizeinvideo'.freeze
  RATE_LIMIT_SLEEP = 1.minute
  LOG_PREFIX = 'Emotion recognition.'.freeze

  def initialize(video_part)
    @video_part = video_part
  end

  def start_processing
    @operation_location = OperationLocationStorage.find(@video_part) || upload_file

    Log.logger.info("#{LOG_PREFIX} Operation location for #{@video_part.period} is #{@operation_location}")
  end

  def happiness_level
    @average_happiness ||= check_status
  end

  private

  def upload_file
    Log.logger.info("#{LOG_PREFIX} Uploading #{@video_part.period} for processing")
    res = request do
      RestClient::Request.execute(method: :post, url: URL, payload: File.new(@video_part.path),
                                  headers: { content_type: 'application/octet-stream' }.merge(key_header))
    end
    Log.logger.info("#{LOG_PREFIX} Uploaded #{@video_part.period} for processing")

    OperationLocationStorage.create(@video_part, res.headers[:operation_location])
    res.headers[:operation_location]
  end

  def check_status
    return @average_happiness if @average_happiness

    Log.logger.info("#{LOG_PREFIX} Checking #{@video_part.period} status")
    check_response = request do
      JSON.parse(RestClient.get(@operation_location, key_header))
    end

    case check_response['status']
    when 'Succeeded'
      process_result(check_response['processingResult'])
      Log.logger.info("#{LOG_PREFIX} Processing #{@video_part.period} successfully finished")
    when 'Running'
      Log.logger.info("#{LOG_PREFIX} Processing #{@video_part.period}, progress is #{check_response['progress']}%")
    when 'Failed'
      Log.logger.error("#{LOG_PREFIX} Processing #{@video_part.period} failed with #{check_response}. Reuploading")
      upload_file
    end
    @average_happiness
  end

  def request(&block)
    begin
      yield
    rescue RestClient::ExceptionWithResponse => e
      case e.response.code
      when 429
        Log.logger.info("#{LOG_PREFIX} Rate limit is exceeded. Sleep for #{RATE_LIMIT_SLEEP.inspect}")
        sleep RATE_LIMIT_SLEEP
        retry
      else
        Log.logger.error("#{LOG_PREFIX} Error processing #{@video_part.period} #{e.response.body}")
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
