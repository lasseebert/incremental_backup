require 'spec_helper'

describe IncrementalBackup::Task do
  it 'should be configured' do
    task = IncrementalBackup::Task.new do |config|
      config.hourly_backups = 1
      config.daily_backups = 2
      config.weekly_backups = 3
      config.montly_backups = 4
    end
    task.settings.hourly_backups.should == 1
    task.settings.daily_backups.should == 2
    task.settings.weekly_backups.should == 3
    task.settings.montly_backups.should == 4
  end

  it 'throws error with invalid settings do' do

    task = IncrementalBackup::Task.new do
    end

    logger_double = double('logger')
    logger_double.should_receive(:error).at_least(:once)
    task.stub(:logger).and_return logger_double

    task.run
  end

  it 'runs' do
    task = IncrementalBackup::Task.new do |settings|
      settings.task_id = "test_test"
      settings.settings_path = "some/path"
      settings.remote_server = "myserver"
      settings.local_path = "some/path"
      settings.remote_path = "some/path"
      settings.remote_user = "me"
    end

    logger_double = double('logger')
    logger_errors = []
    logger_double.stub(:error) { |message| logger_errors << message }
    logger_double.stub(:info)
    task.stub(:logger).and_return logger_double

    task.run

    throw logger_errors.join("\n") if logger_errors.any?
  end
end
