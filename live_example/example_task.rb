#!/usr/bin/env ruby

require 'incremental_backup'

task = IncrementalBackup::Task.new do |settings|

  # Defines the id of the task. This is used to ensure that the backup cannot
  # be running simultaneously in two processes. The name must be a valid file
  # name
  settings.task_id = 'my_backup_task'

  # Defines the maximum number of hourly backups
  settings.hourly_backups = 24

  # The maximum number of daily backups
  settings.daily_backups = 7

  # The maximum number of weekly backups
  settings.weekly_backups = 4

  # The maximum number of monthly backups
  settings.montly_backups = 3

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
