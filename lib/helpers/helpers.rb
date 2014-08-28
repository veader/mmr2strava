module MMRToStrava
  module Helpers

    # ----------------------------------------------------------------------
    # CURRENT X
    def current_user
      @_current_user ||= \
        session[:user_id] ? AuthUser.where(id: session[:user_id].to_i).first : nil
    end

    # ----------------------------------------------------------------------
    # GENERAL
    def oauth_access_required?
      # http://rubular.com/r/v4vJ6eN351
      !request.path_info.match(%r{^/(auth|access|logout)}) && \
      current_user && \
      current_user.needs_access_grants?
    end

    def oauth_access_required!
      redirect "/access" if oauth_access_required?
    end

    def midnight_date_format
      "%Y-%m-01T00:00:00Z"
    end

    def display_in_miles(distance_in_meters)
      "%0.2f" % (distance_in_meters.to_f * 0.00062137)
    end

    def display_time(time_in_secs)
      mins, secs = time_in_secs.to_f.divmod(60)
      hours, mins = mins.divmod(60)
      output = ""
      output += ("%d:" % hours)
      output += ("%02d:%02d" % [mins, secs])
      output
    end

    def class_for_flash(level)
      { error:   "alert-danger",
        warning: "alert-warning",
        notice:  "alert-info",
        info:    "alert-info",
        success: "alert-success",
      }[level]
    end

  end
end
