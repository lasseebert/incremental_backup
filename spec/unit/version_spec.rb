require 'spec_helper'

describe 'version' do
  it 'should have a version' do
    IncrementalBackup::VERSION.should_not be_nil
  end
end
