#!/usr/bin/env ruby

require "dotenv"
Dotenv.load

require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require "sinatra/flash"
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
    provider :strava, ENV["STRAVA_CLIENT_ID"], ENV["STRAVA_CLIENT_SECRET"]
    provider :mapmyfitness, ENV["MMF_API_KEY"], ENV["MMF_API_SECRET"]
  end
  # OmniAuth.config.logger = Logger.new("log/omniauth.log")

  # ---------------------------------------------------------------
  helpers do
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
    redirect "/workouts"
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
  get "/user" do
    erb :user
  end

  get "/access" do
    erb :access
  end

  # ---------------------------------------------------------------
  get "/workouts" do
    # TODO: pagination - pass dates?
    # TODO: date formatter helper
    @month = Date.today
    params = { started_after: @month.strftime(midnight_date_format) }
    @workouts = MMR::Workout.all(current_user.mmr_client, current_user.mmr_user_id, params)
    erb :workouts
  end

  get "/workouts/:year/:month" do
    month_beginning = Date.new(params[:year].to_i, params[:month].to_i, 1)
    month_ending = month_beginning.next_month

    params = { started_after:  month_beginning.strftime(midnight_date_format),
               started_before: month_ending.strftime(midnight_date_format) }
    @workouts = MMR::Workout.all(current_user.mmr_client, current_user.user_id, params)
    @month = month_beginning
    erb :workouts
  end

  get "/workout/:workout_id/download" do
    content_type "text/xml"

    @user = current_user.mmr_user
    @workout = MMR::Workout.find(current_user.mmr_client, params[:workout_id])
    @workout.gpx_builder.to_xml
  end

end
