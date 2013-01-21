#!/usr/bin/env ruby

unless ARGV.length == 1
  puts "Usage: incremental_backup path/to/settings_file"
  exit(1)
end

# Path to settings file is first param
settings_file = ARGV[0]

require 'incremental_backup'
require settings_file

puts 'Hello'

puts %x{ echo "world" }
