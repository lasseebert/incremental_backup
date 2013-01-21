require 'spec_helper'

describe IncrementalBackup::Task do
  it 'should be configured' do
    task = IncrementalBackup::Task.new do |config|
      config.hourly_backups = 24
      config.daily_backups = 7
      config.weekly_backups = 4
      config.montly_backups = 3
    end
    task.settings.hourly_backups.should == 24
    task.settings.daily_backups.should == 7
    task.settings.weekly_backups.should == 4
    task.settings.montly_backups.should == 3
  end
end
