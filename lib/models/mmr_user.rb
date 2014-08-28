module MMR
  class User
    attr_accessor :json

    def initialize(json={})
      self.json = json
    end

    def user_id
      json["id"]
    end

  end
end
