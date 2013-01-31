guard 'rspec' do

  # Run spec if spec changes
  watch(%r{^spec/.+_spec\.rb$})

  # Run all specs if anything changes
  watch(%r{^lib/(.+)\.rb$}) { 'spec' }
  watch('spec/spec_helper.rb')  { 'spec' }
end

