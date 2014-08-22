#!/usr/bin/env ruby

require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require "rack-flash"
require "omniauth"
require "ostruct"
require "date"

require "dotenv"
Dotenv.load

# models ----
require "mmr_client"
require "mmr_user"
require "mmr_workout"

# helpers ----

Time.zone = "UTC"
ActiveRecord::Base.default_timezone = :utc

set :database, ENV["DATABASE_URL"]

class MMRToStravaApplication < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Partial

  set :root, ENV["MAIN_DIR"] # File.join(File.dirname(__FILE__), "..")
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
  use OmniAuth::Strategies::Developer

  # ---------------------------------------------------------------
  helpers do
    # add as needed
  end

  # ---------------------------------------------------------------
  before do
    # authentication_required!
  end

  # ---------------------------------------------------------------
  get "/" do
    redirect "/workouts"
  end

  get "/workouts" do
    # TODO: pagination - pass dates?
    params = { started_after: "2014-08-01T00:00:00Z" }
    @user = MMR::User.current
    @workouts = MMR::Workout.all(@user.user_id, params)
    erb :workouts
  end

  get "/user" do
    @user = MMR::User.current
    erb :user
  end

end
