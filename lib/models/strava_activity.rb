module Strava
  class Activity
    attr_accessor :json

    def self.activities_matching_workout(client, mmr_workout)
      start_of_day = DateTime.parse(mmr_workout.start_datetime.strftime('%Y-%m-%d 00:00:00'))
      end_of_day = start_of_day.next_day
      search_activities(client, before: end_of_day, after: start_of_day)

    end

    def self.search_activities(client, options={})
      client.list_athlete_activities(options).collect { |json| new(json) }
    end

    def initialize(json={})
      self.json = json
    end
  end

end
