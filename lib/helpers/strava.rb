module MMRToStrava
  module Strava
    def handle_strava_oauth
      auth_hash = request.env["omniauth.auth"]
      current_user.strava_user_id = auth_hash["uid"]
      current_user.strava_token = auth_hash["credentials"]["token"]
      current_user.save

      redirect "/"
    end
  end
end
