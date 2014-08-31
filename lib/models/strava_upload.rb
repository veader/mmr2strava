module Strava
  class Upload
    attr_accessor :json

    def initialize(json)
      self.json = json
    end

    def upload_id
      json["id"]
    end

    def external_id
      @_external_id ||= full_external_id.gsub(/\.gpx$/, "") # strip off .gpx
    end

    def full_external_id
      json["external_id"]
    end

    def activity_id
      @_activity_id ||= \
        if match_data = duplicate?
          match_data.captures[0]
        else
          json["activity_id"]
        end
    end

    def status
      json["status"] || ""
    end

    def error
      json["error"] || ""
    end

    def error?
      !duplicate? && !error.blank?
    end

    def duplicate?
      # "710277371.gpx duplicate of activity 187329533"
      # http://rubular.com/r/zthPanKW4j
      error.match(/duplicate of activity (\d+)/)
    end

    def processing?
      # "Your activity is still being processed."
      !error? && status.match(/still being processed/)
    end

    def created?
      # "Your activity is ready."
      !error? && status.match(/activity is ready/)
    end

  end
end
