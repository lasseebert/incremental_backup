require 'spec_helper'

describe IncrementalBackup::TaskSettings do
  it 'should not be valid without settings_path' do
    settings = IncrementalBackup::TaskSettings.new
    settings.should_not be_valid
    settings.errors.length.should == 1
  end
end
