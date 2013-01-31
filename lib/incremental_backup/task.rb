require 'logger'

module IncrementalBackup
  class Task

    LOG_FILENAME = 'log'
    NUM_LOG_FILES = 10

    attr_accessor :settings

    def initialize(&block)
      self.settings = TaskSettings.new
      yield settings
    end

    # Perform the backup
    def run
      validate_settings
    end

    private

    def validate_settings
      throw settings.errors.first unless settings.valid?
      logger.info "Settings validated"
    end

    def logger
      @logger ||= Logger.new(File.join(settings.settings_path, LOG_FILENAME), NUM_LOG_FILES)
    end
  end
end
