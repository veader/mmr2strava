class CreateAuthUsers < ActiveRecord::Migration
  def change
    create_table :auth_users do |t|
      t.string :email
      t.string :name
      t.string :uid
      t.string :token
      t.string :mmr_token
      t.string :mmr_secret
      t.string :mmr_user_id
      t.string :strava_token
      t.string :strava_user_id
      t.timestamps
    end
    add_index :auth_users, :email
  end
end
