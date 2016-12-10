require 'yaml'

class Keys
  SECRETS_PATH = 'secrets.yml'.freeze

  class << self
    def fetch(*key_path)
      result = keys_hash
      key_path.each do |path_part|
        result = result[path_part]
        quit result.blank? do
          Log.logger.error("#{key_path.join(' -> ')} is not provided")
        end
      end
      result
    end

    private

    def keys_hash
      @keys_hash ||= begin
        quit !File.exist?(SECRETS_PATH) || !(yaml = YAML.load(File.read(SECRETS_PATH))) do
          Log.logger.error("Fill in #{SECRETS_PATH} file.")
        end
        yaml.with_indifferent_access
      end
    end

    def quit(condition)
      return unless condition
      yield if block_given?
      puts
      raise ArgumentError
    end
  end
end
