require "mmf"

module MMR
  class Client
    def self.create(auth_token)
      Mmf::Client.new do |config|
        config.client_key    = ENV["MMF_API_KEY"]
        config.client_secret = ENV["MMF_API_SECRET"]
        config.access_token  = auth_token
      end
    end

  end
end
