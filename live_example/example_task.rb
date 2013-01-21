#!/usr/bin/env ruby

require 'incremental_backup'

task = IncrementalBackup::Task.new do |settings|
  settings.hourly_backups = 24
  settings.daily_backups = 7
  settings.weekly_backups = 4
  settings.montly_backups = 3
  settings.settings_path = File.dirname(__FILE__)
end
