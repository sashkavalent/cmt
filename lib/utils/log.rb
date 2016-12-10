require 'fileutils'

class Log
  class MultiIO
    def initialize(*targets)
       @targets = targets
    end

    def write(*args)
      @targets.each {|t| t.write(*args)}
    end

    def close
      @targets.each(&:close)
    end
  end

  def self.logger
    FileUtils.mkdir_p('log')
    @logger ||= Logger.new MultiIO.new(STDOUT, File.open('log/debug.log', 'a'))
  end
end
