require "httmultiparty"
require "gpx_string_io"
require "strava_upload"
require "upload_log"

module Strava
  class Uploader
    include HTTMultiParty
    base_uri "https://www.strava.com/api/v3/"

    attr_accessor :strava_client

    def initialize(client)
      self.strava_client = client
    end

    def upload(mmr_workout=nil)
      return nil if mmr_workout.nil?

      response = self.class.post("/uploads",
        query: {
          name: mmr_workout.better_name,
          external_id: mmr_workout.workout_id,
          data_type: "gpx",
          file: GPXStringIO.new(mmr_workout.gpx_builder, mmr_workout.workout_id),
          access_token: self.strava_client.access_token,
        }
      )
      # TODO: private flag and type

      upload = Strava::Upload.new(response.parsed_response)

      log = UploadLog.where(mmr_workout_id: mmr_workout.workout_id).first
      if log
        log.strava_upload_id ||= upload.upload_id
        log.strava_activity_id ||= upload.activity_id
        log.save
      else
        unless upload.error?
          UploadLog.create(strava_upload_id: upload.upload_id,
                           mmr_workout_id: mmr_workout.workout_id,
                           strava_activity_id: upload.activity_id)
        end
      end

      # return an upload response object
      upload
    end

    def upload_status(upload_log)
      response = \
        self.class.get("/uploads/#{upload_log.strava_upload_id}",
          query: { access_token: self.strava_client.access_token })

      upload = Strava::Upload.new(response.parsed_response)

      upload_log.strava_upload_id ||= upload.upload_id
      upload_log.strava_activity_id ||= upload.activity_id
      upload_log.save

      # return an upload response object
      upload
    end

  end
end
