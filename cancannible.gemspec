# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cancannible/version'

Gem::Specification.new do |spec|
  spec.name          = "cancannible"
  spec.version       = Cancannible::VERSION
  spec.authors       = ["Paul Gallagher"]
  spec.email         = ["paul@evendis.com"]
  spec.summary       = "Dynamic, configurable permissions for CanCan"
  spec.homepage      = "https://github.com/evendis/cancannible"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "activemodel"
  spec.add_runtime_dependency "cancan"

  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
end
