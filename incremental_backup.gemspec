# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'incremental_backup/version'

Gem::Specification.new do |gem|
  gem.name          = "incremental_backup"
  gem.version       = IncrementalBackup::VERSION
  gem.authors       = ["Lasse Skindstad Ebert"]
  gem.email         = ["lasseebert@gmail.com"]
  gem.description   = %q{incremental_backup can make incremental backups by hour/day/week/month/year remotely through ssh and rsync}
  gem.summary       = %q{incremental_backup can make incremental backups by hour/day/week/month/year remotely through ssh and rsync}
  gem.homepage      = 'https://github.com/lasseebert/incremental_backup'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', '~> 2.12'
  gem.add_development_dependency 'rspec-mocks', '~> 2.12'
  gem.add_development_dependency 'guard-rspec', '~> 2.4'
  gem.add_development_dependency 'rb-inotify', '~> 0.8.8'
  gem.add_development_dependency 'rake', '~> 10.0.3'

  gem.add_dependency 'active_attr', '~> 0.7'
  gem.add_dependency 'net-ssh', '~> 2.6'
end
