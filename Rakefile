require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# rake console is fun!
task :console do
  require 'irb'
  require 'irb/completion'
  require 'lita-cricket' # You know what to do.
  ARGV.clear
  IRB.start
end
