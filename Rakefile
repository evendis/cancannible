require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'appraisal'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r cancannible.rb"
end