require "mmf"

module MMR
  class Client
    attr_accessor :client_instance

    def initialize(auth_token)
      self.client_instance = \
        Mmf::Client.new do |config|
          config.client_key    = ENV["MMR_CLIENT_KEY"]
          config.client_secret = ENV["MMR_CLIENT_SECRET"]
          config.access_token  = auth_token
        end
    end

  end
end
