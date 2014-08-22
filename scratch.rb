#!/usr/bin/env ruby

require "dotenv"
require "mmf"
require "nokogiri"
require "date"
require "pp"

Dotenv.load

@mmr_client = \
  Mmf::Client.new do |config|
    config.client_key    = ENV["MMR_CLIENT_KEY"]
    config.client_secret = ENV["MMR_CLIENT_SECRET"]
    config.access_token  = ENV["MMR_ACCESS_TOKEN"]
  end

# returns JSON user object
def get_current_user
  @mmr_client.me
end

# returns collection of JSON workout objects
def get_workouts_for_user(user_id, options={})
  final_options = options.merge(user: user_id)
  @mmr_client.workouts(final_options)
end

# returns JSON workout object
def get_workout(workout_id)
  @mmr_client.workout(workout_id: workout_id, field_set: "time_series")
end

# returns Nokogiri builder
def create_gpx_for_workout(workout)
  # TODO: change creator
  gpx_namespace_bs = {
    "version"             => "1.1",
    "creator"             => "MMR_Workout_Converter",
    "xmlns"               => "http://www.topografix.com/GPX/1/1",
    "xmlns:xsi"           => "http://www.w3.org/2001/XMLSchema-instance",
    "xsi:schemaLocation"  => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd",
    "xmlns:gpxtpx"        => "http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd",
  }

  # example: 2014-08-13T11:48:45Z
  time_format = "%Y-%m-%dT%H:%M:%SZ"
  start_time = DateTime.parse(workout["start_datetime"])
  time_series = workout["time_series"]
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
              hr_data = series_data["heartrate"][index]

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

# -------------------------------------------------------------------------
json_me = get_current_user
json_workouts = get_workouts_for_user(json_me["id"], started_after: "2014-08-01T00:00:00Z")
pp json_workouts

# gpx = create_gpx_for_workout(get_workout(688203659))
# File.open("./tmp/generated.xml", "w+") do |f|
#   f << gpx.to_xml
# end
