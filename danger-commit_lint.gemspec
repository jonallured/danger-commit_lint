# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commit_lint/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-commit_lint'
  spec.version       = CommitLint::VERSION
  spec.authors       = ['Jon Allured']
  spec.email         = ['jon.allured@gmail.com']
  spec.description   = %q{A short description of danger-commit_lint.}
  spec.summary       = %q{A longer description of danger-commit_lint.}
  spec.homepage      = 'https://github.com/Jon Allured/danger-commit_lint'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger', '~>3.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency "rubocop", "~> 0.41"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency 'pry'
end
