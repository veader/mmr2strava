# A sample Gemfile
source "https://rubygems.org"
# ruby "2.0.0"

gem "rake"

# web ----
gem "rack"
gem "sinatra"
gem "sinatra-flash"
gem "sinatra-partial"
gem "sinatra-contrib"
gem "json"
gem "sinatra-activerecord"

# authentication ----
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-strava"
gem "omniauth-mapmyfitness-oauth2"

# api ----
gem "mmf"
gem "dotenv"
gem "nokogiri"
gem "strava-api-v3"
gem "httmultiparty"

group :development do
  # database ----
  # gem "sqlite3" # technically only needed for dev
  gem "mysql2"
  # gem "pg"

  # dev/debugging ----
  gem "tux"
  # gem "capistrano", "2.15.5"
end

group :production do
  # database ----
  gem "pg"
  # webserver ----
  gem "unicorn"
end

group :test do
  gem "mocha"
  gem "simplecov", "~> 0.7.1"
  gem "rack-test"
end
