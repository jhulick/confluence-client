require 'bundler'
require 'rspec/core/rake_task'
require 'rdoc-readme/rake_task'

Bundler::GemHelper.install_tasks
RDoc::Readme::RakeTask.new 'lib/confluence-client.rb', 'README.rdoc'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

