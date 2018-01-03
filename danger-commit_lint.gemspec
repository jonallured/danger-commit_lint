# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commit_lint/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-commit_lint'
  spec.version       = CommitLint::VERSION
  spec.authors       = ['Jon Allured']
  spec.email         = ['jon.allured@gmail.com']
  spec.description   = 'A Danger Plugin that ensures nice and tidy commit messages.'
  spec.summary       = "A Danger Plugin that ensure commit messages are not too long, don't end in a period and have a line between subject and body"
  spec.homepage      = 'https://github.com/jonallured/danger-commit_lint'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger', '~> 5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
end
