require "nokogiri"

module MMR
  class Workout
    attr_accessor :json

    def self.all(client, user_id, options={})
      final_options = options.merge(user: user_id)
      json_workouts = client.workouts(final_options)
      json_workouts.collect { |json| new(json) }
    end

    def self.all_for_month(client, user_id, date=Date.today)
      month_beginning = Date.new(date.year, date.month, 1)
      month_ending = month_beginning.next_month
      midnight_format = "%Y-%m-%dT00:00:00Z"

      params = { started_after:  month_beginning.strftime(midnight_format),
                 started_before: month_ending.strftime(midnight_format) }
      all(client, user_id, params)
    end

    def self.find(client, workout_id)
      json_workout = client.workout(workout_id: workout_id, field_set: "time_series")
      new(json_workout) if json_workout
    end

    def initialize(json={})
      self.json = json
    end

    # def json_map
    #   {
    #     workout_id: "_links/self/[0]/id",
    #   }
    # end

    def workout_id
      @_workout_id ||= self.json["_links"]["self"].first["id"]
    end

    def name
      @_name ||= self.json["name"]
    end

    def better_name
      @_better_name ||= \
        if self.name == "Run"
          "Run on #{start_datetime.strftime('%m/%d/%Y')}"
        else
          self.name
        end
    end

    def start_datetime
      @_start_datetime ||= DateTime.parse(self.json["start_datetime"])
    end

    def distance_total
      @_distance_total ||= self.json["aggregates"]["distance_total"]
    end

    def elapsed_time_total
      @_elapsed_time_total ||= self.json["aggregates"]["elapsed_time_total"]
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
