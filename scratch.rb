#!/usr/bin/env ruby

require "dotenv"
require "mmf"
require "nokogiri"
require "date"
require "pp"

Dotenv.load

mmr_client = \
  Mmf::Client.new do |config|
    config.client_key    = ENV["MMR_CLIENT_KEY"]
    config.client_secret = ENV["MMR_CLIENT_SECRET"]
    config.access_token  = ENV["MMR_ACCESS_TOKEN"]
  end

# puts "-"*80
# json_me = mmr_client.me
# pp json_me
# puts "-"*80
# json_workouts = mmr_client.workouts(user: json_me["id"])
# pp json_workouts
workout = mmr_client.workout(workout_id: 688203659, field_set: "time_series")
pp workout
puts "-"*80


# TODO: change creator
gpx_namespace_bs = {
  "version"             => "1.1",
  "creator"             => "MMR_Workout_Converter",
  "xmlns"               => "http://www.topografix.com/GPX/1/1",
  "xmlns:xsi"           => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation"  => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd",
  "xmlns:gpxtpx"        => "http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd",
}

# 2014-08-13T11:48:45Z
time_format = "%Y-%m-%dT%H:%M:%SZ"
start_time = DateTime.parse(workout["start_datetime"])
time_series = workout["time_series"]
time_series = [time_series] unless time_series.is_a?(Array)

builder = \
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

File.open("./tmp/generated.xml", "w+") do |f|
  f << builder.to_xml
end
# puts builder.to_xml
