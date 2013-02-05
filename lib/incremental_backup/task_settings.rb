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

    # Path to the exclude file, containing all files and dirs not to include
    attribute :exclude_file

    # Paths
    attribute :local_path
    attribute :remote_path

    # Login
    attribute :remote_server
    attribute :remote_user
    attribute :ssh_key_path

    # Validation
    validates :task_id, presence: true
    validates :settings_path, presence: true
    validates :remote_server, presence: true
    validates :local_path, presence: true
    validates :remote_path, presence: true
    validates :remote_user, presence: true
    validates :ssh_key_path, presence: true

  end
end
