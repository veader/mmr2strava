#!/usr/bin/env ruby

require "dotenv"
Dotenv.load

require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require "sinatra/flash"
require "sinatra/content_for"
require "sinatra/json"
require "omniauth"
require "omniauth-google-oauth2"
require "omniauth-strava"
require "omniauth-mapmyfitness-oauth2"
require "ostruct"
require "date"

# models ----
require "auth_user"
require "mmr_user"
require "mmr_workout"
require "strava_activity"
require "strava_uploader"

# helpers ----
require "app_env"
require "helpers"
require "authentication"
require "get_or_post"
require "mapmyfitness"
require "strava"

# Time.zone = "UTC"
ActiveRecord::Base.default_timezone = :utc

set :database, ENV["DATABASE_URL"]

class MMRToStravaApplication < Sinatra::Base
  include MMRToStrava::AppEnv
  include MMRToStrava::Authentication

  register Sinatra::ActiveRecordExtension
  register Sinatra::Partial
  register Sinatra::Flash
  register Sinatra::GetOrPost

  set :root, ENV["MAIN_DIR"]
  set :partial_template_engine, :erb

  # useful for debugging....
  # set :logging, true
  # set :dump_errors, true
  # set :raise_errors, true
  # set :show_exceptions, true

  # enable :sessions # use explicit so we can set session secret
  use Rack::Session::Cookie, {  key: "rack.session",
                                path: "/",
                                expire_after: 2592000,
                                secret: ENV["SESSION_SECRET"],
                              }

  # keys found here: https://cloud.google.com/console
  use OmniAuth::Builder do
    if ENV["RACK_ENV"] == "development"
      provider :developer
    else
      provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
               { name: "google", access_type: "online" }
    end
    provider :strava, ENV["STRAVA_CLIENT_ID"], ENV["STRAVA_CLIENT_SECRET"], scope: "view_private write"
    provider :mapmyfitness, ENV["MMF_API_KEY"], ENV["MMF_API_SECRET"]
  end
  # OmniAuth.config.logger = Logger.new("log/omniauth.log")

  # ---------------------------------------------------------------
  helpers do
    include Sinatra::ContentFor
    include Sinatra::JSON
    include MMRToStrava::Helpers
    include MMRToStrava::MapMyFitness
    include MMRToStrava::Strava
  end

  # ---------------------------------------------------------------
  before do
    authentication_required!
    oauth_access_required! # need to have MMR and Strava access
  end

  after do
    flash.sweep
  end

  # ---------------------------------------------------------------
  get "/" do
    redirect "/mmr/workouts"
  end

  get "/login" do
    erb :login
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  get_or_post "/auth/:name/callback" do
    case params[:name]
    when "strava"
      handle_strava_oauth
    when "mapmyfitness"
      handle_mapmyfitness_oauth
    else
      handle_oauth_callback
    end
  end

  get_or_post "/auth/failure" do
    session.clear
    @auth_hash = request.env["omniauth.auth"]
    @failure_message = params[:message]
    erb :auth_failure
  end

  # ---------------------------------------------------------------
  get "/account/settings" do
    erb :user
  end

  get "/access" do
    erb :access
  end

  # ---------------------------------------------------------------
  # Strava
  get "/strava/activities" do
    today = Date.today
    redirect "/strava/activities/#{today.year}/#{today.month}"
  end

  get "/strava/activities/:year/:month" do
    @month = Date.new(params[:year].to_i, params[:month].to_i, 1)
    @activities = \
      Strava::Activity.all_for_month(current_user.strava_client, @month)
    erb :strava_activities
  end

  get "/strava/disconnect" do
    current_user.disconnect_strava!
    redirect "/account/settings"
  end

  # ---------------------------------------------------------------
  # MapMyRun
  get "/mmr/workouts" do
    today = Date.today
    redirect "/mmr/workouts/#{today.year}/#{today.month}"
  end

  get "/mmr/workouts/:year/:month" do
    @month = Date.new(params[:year].to_i, params[:month].to_i, 1)
    @workouts = \
      MMR::Workout.all_for_month(current_user.mmr_client, current_user.mmr_user_id, @month)
    erb :mmr_workouts
  end

  get "/mmr/disconnect" do
    current_user.disconnect_mmr!
    redirect "/account/settings"
  end

  get "/mmr/workout/:workout_id/download" do
    content_type "text/xml"

    @workout = MMR::Workout.find(current_user.mmr_client, params[:workout_id])
    @workout.gpx_builder.to_xml
  end

  get "/mmr/workout/:workout_id/upload" do
    @workout = MMR::Workout.find(current_user.mmr_client, params[:workout_id])
    @month = @workout.start_datetime
    erb :upload
  end

  # AJAX calls ------
  get "/mmr/workout/:workout_id/upload/start" do
    @workout = MMR::Workout.find(current_user.mmr_client, params[:workout_id])

    uploader = Strava::Uploader.new(current_user.strava_client)
    # response = uploader.upload(@workout)

    # TODO: save upload state
    # TODO: check response

    erb :upload_poll, layout: false
  end

  get "/mmr/workout/:workout_id/upload/poll" do
    # TODO : load saved upload state, query, strava and branch response
    # TODO : handle error and render different partial

    sleep 10

    # next step is to do the upload
    erb :upload_scanning, layout: false
  end

end
