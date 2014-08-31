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
  desc "Upload workouts for a given month"
  task :upload_month do
    @month = Date.new(ENV["YEAR"].to_i, ENV["MONTH"].to_i, 1)
    @user = AuthUser.first # TODO: this needs to change...
    @workouts = \
      MMR::Workout.all_for_month(@user.mmr_client, @user.mmr_user_id, @month)
    @uploader = Strava::Uploader.new(@user.strava_client)

    @workouts.each do |workout|
      # check for previous log
      log = UploadLog.where(mmr_workout_id: workout.workout_id).first
      next if log && log.complete?

      uploading = true
      response = @uploader.upload(workout)

      while uploading do
        if response.error?
          puts "Error uploading workout: #{workout.workout_id}"
          break
        elsif response.duplicate?
          puts "Duplicate workout detected: #{workout.workout_id}"
          break
        elsif response.processing?
          print "."
          sleep 5
          log = UploadLog.where(mmr_workout_id: workout.workout_id).first
          response = @uploader.upload_status(log)
        elsif response.created?
          puts "Success!"
          uploading = false
        else
          puts "Unknown response status?"
          break
        end
      end # -- while
    end # -- workouts.each
  end

end

# ----------------------------------------------------------------------------
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
  test.warning = true
end
