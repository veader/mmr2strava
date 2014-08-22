require "mmf"
require "mmr_workout"

module MMR
  class Client
    def self.instance
      @_client_instance ||= \
        Mmf::Client.new do |config|
          config.client_key    = ENV["MMR_CLIENT_KEY"]
          config.client_secret = ENV["MMR_CLIENT_SECRET"]
          config.access_token  = ENV["MMR_ACCESS_TOKEN"]
        end
    end

  end
end
