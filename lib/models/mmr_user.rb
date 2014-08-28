module MMR
  class User
    def self.current
      @_current ||= new(Client.instance.me)
    end

    attr_accessor :json

    def initialize(json={})
      self.json = json
    end

    def user_id
      json["id"]
    end

  end
end
