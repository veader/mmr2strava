#!/usr/bin/env ruby

require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require "rack-flash"
require "omniauth"
require "omniauth-google-oauth2"
require "ostruct"
require "date"

require "dotenv"
Dotenv.load

# models ----
require "mmr_client"
require "mmr_user"
require "mmr_workout"
require "auth_user"

# helpers ----
require "app_env"
require "helpers"
require "authentication"
require "get_or_post"

# Time.zone = "UTC"
ActiveRecord::Base.default_timezone = :utc

set :database, ENV["DATABASE_URL"]

class MMRToStravaApplication < Sinatra::Base
  include MMRToStrava::AppEnv
  include MMRToStrava::Authentication

  register Sinatra::ActiveRecordExtension
  register Sinatra::Partial
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

  use Rack::Flash, :sweep => true

  if is_development?
    use OmniAuth::Strategies::Developer
  else
    OmniAuth.config.full_host = ENV["FULL_DOMAIN"] if is_production?

    # keys found here: https://cloud.google.com/console
    use OmniAuth::Builder do
      provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
               { name: "google", access_type: "online" }
      # prompt: "consent" # <-- add to hash to "force" reset
    end
    OmniAuth.config.logger = Logger.new("log/omniauth.log")
  end

  # ---------------------------------------------------------------
  helpers do
    include MMRToStrava::Helpers
  end

  # ---------------------------------------------------------------
  before do
    authentication_required!
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
    handle_oauth_callback
  end

  get_or_post "/auth/failure" do
    session.clear
    @auth_hash = request.env["omniauth.auth"]
    @failure_message = params[:message]
    erb :auth_failure
  end

  # ---------------------------------------------------------------
  get "/user" do
    @user = MMR::User.current
    erb :user
  end

  # ---------------------------------------------------------------
  get "/workouts" do
    # TODO: pagination - pass dates?
    # TODO: date formatter helper
    @month = Date.today
    params = { started_after: @month.strftime(midnight_date_format) }
    @user = MMR::User.current
    @workouts = MMR::Workout.all(@user.user_id, params)
    erb :workouts
  end

  get "/workouts/:year/:month" do
    month_beginning = Date.new(params[:year].to_i, params[:month].to_i, 1)
    month_ending = month_beginning.next_month

    params = { started_after:  month_beginning.strftime(midnight_date_format),
               started_before: month_ending.strftime(midnight_date_format) }
    @user = MMR::User.current
    @workouts = MMR::Workout.all(@user.user_id, params)
    @month = month_beginning
    erb :workouts
  end

  get "/workout/:workout_id/download" do
    content_type "text/xml"

    @user = MMR::User.current
    @workout = MMR::Workout.find(params[:workout_id])
    @workout.gpx_builder.to_xml
  end

end
