require 'spec_helper'

describe IncrementalBackup::Lock do

  # Mocks
  let(:task) { double("task", logger: logger, settings: settings) }
  let(:logger) { double("logger", info: nil) }
  let(:settings) { double("settings", settings_path: settings_path, task_id: task_id) }

  # Settings
  let(:settings_path) { File.join __dir__, "..", "tmp" }
  let(:task_id) { "example_task" }


  it 'can run' do
    ran = false
    IncrementalBackup::Lock.create task do
      ran = true
    end
    ran.should be_true
  end

  it 'can lock' do
    ran_outer = false
    ran_inner = false

    IncrementalBackup::Lock.create task do
      ran_outer = true
      IncrementalBackup::Lock.create task do
        ran_inner = true
      end
    end
    ran_outer.should be_true
    ran_inner.should be_false
  end
end
