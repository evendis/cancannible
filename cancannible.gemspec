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
  spec.description   = "Extends CanCan with dynamic, inheritable permissions stored in a database, with caching and multi-tenant refinements"
  spec.homepage      = "https://github.com/evendis/cancannible"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 6.1"
  spec.add_runtime_dependency "activemodel", "~> 6.1"
  spec.add_runtime_dependency "cancancan"

  spec.add_development_dependency "activerecord", "~> 6.1"
  spec.add_development_dependency "sqlite3", ">= 1.3.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rb-fsevent"
end
