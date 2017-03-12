require 'English'

class System
  class << self
    def run(command)
      command << ' 2>&1'
      Log.logger.debug("Running #{Color.blue(command)}")
      result = `#{command}`
      handle_error(command, result) unless $CHILD_STATUS.success?
      result
    end

    private

    def handle_error(command, error_output)
      Log.logger.error("Error running #{Color.red(command)}\n#{error_output}")
      exit
    end
  end
end
