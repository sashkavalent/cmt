class OperationLocationStorage
  FILE_NAME = 'operation_locations.yml'.freeze

  class << self
    def find(video_part)
      location = load_hash[video_part.path]
      if location
        Log.logger.info("Emotion recognition. Fetched operation location for #{video_part.period} from #{FILE_NAME}")
      end
      location
    end

    def create(video_part, operation_location)
      h = load_hash
      h[video_part.path] = operation_location
      File.write(FILE_NAME, h.to_yaml)
    end

    private

    def load_hash
      YAML.load(File.read(FILE_NAME)) || {}
    end
  end
end
