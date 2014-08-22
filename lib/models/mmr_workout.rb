require "mmr_client"

module MMR
  class Workout
    attr_accessor :json

    def self.all(user_id, options={})
      final_options = options.merge(user: user_id)
      json_workouts = MMR::Client.instance.workouts(final_options)
      json_workouts.collect { |json| new(json) }
    end

    def initialize(json={})
      self.json = json
    end

  end

end
