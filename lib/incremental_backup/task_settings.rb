module IncrementalBackup
  class TaskSettings
    attr_accessor :hourly_backups,
      :daily_backups,
      :weekly_backups,
      :montly_backups,

      # Path to store log file, lock file and more
      :settings_path

    def valid?
      errors << 'settings_path is missing' if settings_path.nil?
      errors.empty?
    end

    def errors
      @errors ||= []
    end

  end
end
