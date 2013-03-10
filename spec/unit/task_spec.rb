require 'spec_helper'

describe IncrementalBackup::Task do

  let(:task) do
    task = IncrementalBackup::Task.new do |settings|
      settings.yearly_backups = yearly_backups

      settings.task_id = "test_test"
      settings.settings_path = "some/path"
      settings.remote_server = "myserver"
      settings.local_path = "some/path"
      settings.remote_path = "some/path"
      settings.remote_user = "me"
    end

    logger_double = double('logger')
    logger_double.stub(:error) { |message| logger_errors << message }
    logger_double.stub(:info)
    task.stub(:logger).and_return logger_double

    task.stub(:execute_ssh)
    task.stub(:list_backup_dir).and_return(list_backup_dir)

    IncrementalBackup::Lock.stub(:create).and_yield
    IncrementalBackup::Rsync.stub(:execute)

    task
  end

  let(:logger_errors) { [] }
  let(:yearly_backups) { 100 }
  let(:list_backup_dir) do
    [
      "/hourly/backup_2013-02-14-T10-39-27",
      "/hourly/backup_2013-02-14-T10-21-43",
      "/hourly/backup_2013-02-14-T11-02-46",
      "/hourly/backup_2013-02-14-T10-35-04",
      "/hourly/backup_2013-02-14-T10-28-11",
      "/hourly/backup_2013-02-14-T10-33-24"
    ]
  end

  it 'should be configured' do
    task = IncrementalBackup::Task.new do |config|
      config.hourly_backups = 1
      config.daily_backups = 2
      config.weekly_backups = 3
      config.monthly_backups = 4
    end
    task.settings.hourly_backups.should == 1
    task.settings.daily_backups.should == 2
    task.settings.weekly_backups.should == 3
    task.settings.monthly_backups.should == 4
  end

  it 'throws error with invalid settings do' do

    task = IncrementalBackup::Task.new do
    end

    logger_double = double('logger')
    logger_double.should_receive(:error).at_least(:once)
    task.stub(:logger).and_return logger_double

    task.run
  end

  context 'when yearly is set to zero' do
    subject { task }
    let(:yearly_backups) { 0 }
    let(:list_backup_dir) { [] }

    its(:find_schedule) { should == :monthly }
  end

  it 'runs' do


    task.run

    throw logger_errors.join("\n") if logger_errors.any?
  end
end
