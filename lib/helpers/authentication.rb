module MMRToStrava
  module Authentication
    def page_requires_authentication?
      # pages that do not require authentication are login, /auth/ and the complete paths
      paths_without_auth = ["/login"]

      ( !paths_without_auth.include?(request.path_info) && \
        !request.path_info.match(%r{^/auth/})
       )
    end

    def authentication_required?
      page_requires_authentication? && !current_user
    end

    def authentication_required!
      redirect "/login" if authentication_required?
    end

    def login_oauth_path
      self.class.is_development? ? "/auth/developer" : "/auth/google"
    end

    def handle_oauth_callback
      session.clear
      auth_hash = request.env["omniauth.auth"]

      user = AuthUser.find_or_create_by_omniauth(auth_hash)
      if user && user.valid?
        session[:user_id] = user.id

        # redirect to the requested URL if we have one stashed
        # origin = request.env['omniauth.origin']
        # path_for_redirect = \
        #   if !origin.blank? && origin !~ %r{/sessions/new}
        #     origin
        #   else
        #     root_url
        #   end

        redirect "/"
      else
        session[:user_id] = nil
        error_str = "Unable to authenticate.\n" + user.errors.full_messages.join("\n")

        flash[:error] = error_str
        redirect "/login"
      end
    end

  end
end
