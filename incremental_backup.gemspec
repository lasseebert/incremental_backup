# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'incremental_backup/version'

Gem::Specification.new do |gem|
  gem.name          = "incremental_backup"
  gem.version       = IncrementalBackup::VERSION
  gem.authors       = ["Lasse Skindstad Ebert"]
  gem.email         = ["lasseebert@gmail.com"]
  gem.description   = %q{(NOT YET WORKING...) incremental_backup can make incremental backups by hour/day/week/month remotely through ssh and rsync}
  gem.summary       = %q{(NOT YET WORKING...) incremental_backup can make incremental backups by hour/day/week/month remotely through ssh and rsync}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
