# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run application console (pry)'
task :console => :print_env do
  sh 'pry -r ./specs/test_load_all'
end

desc 'Rake all the Ruby'
task :style do
  `rubocop .`
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/**/*_spec.rb'
  t.warning = false
end

desc 'Rerun tests on live code changes'
task :respec do
  sh 'rerun -c rake spec'
end

desc 'Runs rubocop on tested code'
task :style do
  sh 'rubocop .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task :release? => [:spec, :style, :audit] do
  puts "\nReday for release!"
end

namespace :run do
  desc 'Run in development mode'
  task :dev do
    sh 'rackup -p 9292'
  end
end
