module Strava
  class Activity
    attr_accessor :json

    def self.all_for_month(client, date=Date.today)
      month_beginning = Date.new(date.year, date.month, 1)
      month_ending = month_beginning.next_month
      results = \
        client.list_athlete_activities(before: month_ending.to_time.to_i, after: month_beginning.to_time.to_i)
      results.collect { |json| new(json) }
    end

    def initialize(json={})
      self.json = json
    end

    def activity_id
      @_activity_id ||= self.json["id"]
    end

    def name
      @_name ||= self.json["name"]
    end

    def start_datetime
      @_start_datetime ||= DateTime.parse(self.json["start_date"])
    end

    def distance
      @_distance ||= self.json["distance"].to_f
    end

    def elapsed_time
      @_elapsed_time ||= self.json["elapsed_time"].to_f
    end

    def has_heartrate?
      !self.json["max_heartrate"].nil?
    end

  end
end
