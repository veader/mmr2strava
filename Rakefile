#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

MAIN_DIR=File.dirname(__FILE__)
ENV["MAIN_DIR"]=MAIN_DIR

$:.unshift MAIN_DIR
$:.unshift "#{MAIN_DIR}/lib/"
$:.unshift "#{MAIN_DIR}/lib/models/"
$:.unshift "#{MAIN_DIR}/lib/helpers/"

require "rubygems"
require "bundler/setup"
require "rake/testtask"
require "app"
require "sinatra/activerecord/rake"

task :default => [:test]

# ----------------------------------------------------------------------------
namespace :mmr2strava do
end

# ----------------------------------------------------------------------------
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
  test.warning = true
end
