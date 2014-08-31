require "bundler/gem_tasks"
require 'rake/testtask'
require 'rake/clean'

directory 'tmp'

Rake::TestTask.new(:test) do |t|
  t.libs.push 'lib'
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end
