class CreateUploadLog < ActiveRecord::Migration
  def change
    create_table :upload_logs do |t|
      t.string :strava_upload_id
      t.string :mmr_workout_id
      t.string :strava_activity_id
      t.timestamps
    end
    add_index :upload_logs, :strava_upload_id
    add_index :upload_logs, :mmr_workout_id
    add_index :upload_logs, :strava_activity_id
  end
end
