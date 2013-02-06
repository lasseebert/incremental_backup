require 'spec_helper'

describe IncrementalBackup::Task do
  it 'should be configured' do
    task = IncrementalBackup::Task.new do |config|
      config.hourly_backup_days = 1
      config.daily_backup_days = 2
      config.weekly_backup_days = 3
      config.montly_backup_days = 4

      #config.settings_path = File.dirname(__FILE__)

    end
    task.settings.hourly_backup_days.should == 1
    task.settings.daily_backup_days.should == 2
    task.settings.weekly_backup_days.should == 3
    task.settings.montly_backup_days.should == 4
  end
end
