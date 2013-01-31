module IncrementalBackup
  class TaskSettings
    attr_accessor :hourly_backups,
      :daily_backups,
      :weekly_backups,
      :montly_backups,

      # Unique task id, must be a valid file name
      :task_id,

      # Path to store log file, lock file and more
      :settings_path

    def valid?
      errors << 'settings_path is missing' if settings_path.nil?
      errors << 'task_id is missing' if task_id.nil?
      errors.empty?
    end

    def errors
      @errors ||= []
    end

  end
end
