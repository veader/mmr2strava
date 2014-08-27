module MMRToStrava
  module MapMyFitness
    def handle_mapmyfitness_oauth
      auth_hash = request.env["omniauth.auth"]
      current_user.mmr_user_id = auth_hash["uid"]
      current_user.mmr_token = auth_hash["credentials"]["token"]
      current_user.save

      redirect "/"

    end
  end
end
