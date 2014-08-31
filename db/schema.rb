# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140830212802) do

  create_table "auth_users", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "uid"
    t.string   "token"
    t.string   "mmr_token"
    t.string   "mmr_user_id"
    t.string   "strava_token"
    t.string   "strava_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auth_users", ["email"], name: "index_auth_users_on_email"

  create_table "upload_logs", force: true do |t|
    t.string   "strava_upload_id"
    t.string   "mmr_workout_id"
    t.string   "strava_activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_logs", ["mmr_workout_id"], name: "index_upload_logs_on_mmr_workout_id"
  add_index "upload_logs", ["strava_activity_id"], name: "index_upload_logs_on_strava_activity_id"
  add_index "upload_logs", ["strava_upload_id"], name: "index_upload_logs_on_strava_upload_id"

end
