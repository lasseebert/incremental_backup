#!/usr/bin/env ruby

require 'incremental_backup'

task = IncrementalBackup::Task.new do |settings|

  # Defines the id of the task. This is used to ensure that the backup cannot
  # be running simultaneously in two processes. The name must be a valid file
  # name
  settings.task_id = 'my_backup_task'

  # Defines the days to keep backups
  settings.hourly_backup_days = 1
  settings.daily_backup_days = 7
  settings.weekly_backup_days = 30
  settings.montly_backup_days = 100

  # This is where all helper files are saved. These include a log file, a lock
  # file and a file remembering the dates of the the last backups. This would
  # typically be a hidden directory in the home folder, e.g. ~/.incremental_backup
  settings.settings_path = File.dirname(__FILE__)

  # Login options
  settings.remote_server = 'raspi'
  settings.remote_user = 'pulver'

  # Paths
  settings.local_path = '~'
  settings.remote_path = '~/backup/incremental'

  # Exclude all the files and folder listed in this file
  settings.exclude_file = File.join File.dirname(__FILE__), 'exclude.file'
end

task.run
