require "httmultiparty"
require "gpx_string_io"

module Strava
  class Uploader
    include HTTMultiParty
    base_uri "https://www.strava.com/api/v3/"

    attr_accessor :strava_client

    def initialize(client)
      self.strava_client = client
    end

    def upload(mmr_workout)
      self.class.post("/uploads",
        query: {
          name: mmr_workout.name,
          external_id: mmr_workout.workout_id,
          data_type: "gpx",
          file: GPXStringIO.new(mmr_workout.gpx_builder, mmr_workout.workout_id),
          access_token: self.strava_client.access_token,
        }
      )
      # TODO: private flag and type
    end

    def upload_status(strava_client, upload_id)
      self.class.get("/uploads/#{upload_id}",
        query: { access_token: self.strava_client.access_token })
    end

    # def headers
    #   { "Authorization" => self.strava_client.access_token,
    #   }
    # end

  end
end
