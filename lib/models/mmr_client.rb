require "mmf"

module MMR
  class Client
    def self.instance(auth_user)
      @_client_instance ||= \
        Mmf::Client.new do |config|
          config.client_key    = ENV["MMR_CLIENT_KEY"]
          config.client_secret = ENV["MMR_CLIENT_SECRET"]
          config.access_token  = auth_user.mmr_token
        end
    end

  end
end
