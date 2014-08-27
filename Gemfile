# A sample Gemfile
source "https://rubygems.org"

gem "rake"

# web ----
gem "rack"
gem "sinatra"
gem "rack-flash3"
gem "sinatra-partial"
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

group :development do
  # database ----
  gem "sqlite3" # technically only needed for dev
  # gem "mysql2"

  # dev/debugging ----
  gem "tux"
  # gem "capistrano", "2.15.5"
end

group :production do
  # database ----
  gem "pg"
end

group :test do
  gem 'mocha'
  gem "simplecov", "~> 0.7.1"
  gem "rack-test"
end
