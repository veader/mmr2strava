class UploadLog < ActiveRecord::Base
  validates_uniqueness_of :mmr_workout_id
  validates_uniqueness_of :strava_activity_id

  def complete?
    !self.mmr_workout_id.blank? && !self.strava_activity_id.blank?
  end

end
