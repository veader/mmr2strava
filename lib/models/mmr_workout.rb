require "mmr_client"
require "nokogiri"

module MMR
  class Workout
    attr_accessor :json

    def self.all(user_id, options={})
      final_options = options.merge(user: user_id)
      json_workouts = MMR::Client.instance.workouts(final_options)
      json_workouts.collect { |json| new(json) }
    end

    def self.find(workout_id)
      json_workout = MMR::Client.instance.workout(workout_id: workout_id,
                                                  field_set: "time_series")
      new(json_workout)
    end

    def initialize(json={})
      self.json = json
    end

    def workout_id
      self.json["_links"]["self"].first["id"]
    end

    def has_heartrate_data?
      !self.json["aggregates"]["heartrate_avg"].nil?
    end

    def gpx_builder
      # TODO: change creator
      gpx_namespace_bs = {
        "version"             => "1.1",
        "creator"             => "MMR2Strava",
        "xmlns"               => "http://www.topografix.com/GPX/1/1",
        "xmlns:xsi"           => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation"  => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd",
        "xmlns:gpxtpx"        => "http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd",
      }

      # example: 2014-08-13T11:48:45Z
      time_format = "%Y-%m-%dT%H:%M:%SZ"
      start_time = DateTime.parse(self.json["start_datetime"])
      time_series = self.json["time_series"]
      time_series = [time_series] unless time_series.is_a?(Array)

      Nokogiri::XML::Builder.new do |xml|
        xml.gpx(gpx_namespace_bs) do
          xml.metadata {
            xml.time start_time.strftime(time_format)
          }
          xml.trk {
            time_series.each do |series_data|
              xml.trkseg {
                series_data["position"].each_with_index do |pos_data, index|
                  second, position = pos_data
                  pos_time = (start_time.to_time + second.to_f).to_datetime
                  has_heartrate = !series_data["heartrate"].nil?
                  hr_data = has_heartrate ? series_data["heartrate"][index] : nil

                  xml.trkpt(lat: position["lat"], lon: position["lng"]) do
                    xml.ele position["elevation"]
                    xml.time pos_time.strftime(time_format)
                    xml.extensions {
                      xml["gpxtpx"].TrackPointExtension {
                        xml["gpxtpx"].hr hr_data[1].to_i
                      }
                    } if hr_data
                  end
                end
              }
            end
          }
        end
      end
    end

  end

end
