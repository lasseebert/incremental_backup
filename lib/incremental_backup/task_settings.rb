require 'active_attr'
module IncrementalBackup
  class TaskSettings
    include ActiveAttr::Model

    # Max backups to keep
    attribute :hourly_backups, default: 24
    attribute :daily_backups, default: 7
    attribute :weekly_backups, default: 4
    attribute :montly_backups, default: 3

    # Unique task id, must be a valid file name
    attribute :task_id

    # Path to store log file, lock file and more
    attribute :settings_path

    # Remote server
    attribute :remote_server


    # Validation
    validates :task_id, presence: true
    validates :settings_path, presence: true
    validates :remote_server, presence: true

  end
end
