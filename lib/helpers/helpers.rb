module MMRToStrava
  module Helpers

    # ----------------------------------------------------------------------
    # CURRENT X
    def current_user
      @_current_user ||= \
        session[:user_id] ? AuthUser.where(id: session[:user_id].to_i).first : nil
    end

    def current_log
      @_current_log ||= \
        UploadLog.where(mmr_workout_id: params[:workout_id]).first
    end

    # ----------------------------------------------------------------------
    # PATH HELPERS
    def workouts_path_for_month(site, month)
      "/#{site}/#{site == :mmr ? 'workouts' : 'activities'}/#{month.year}/#{month.month}"
    end

    def workout_upload_path(state="poll")
      "/mmr/workout/#{params[:workout_id]}/upload/#{state}"
    end

    def active_tab(site)
      case site.to_sym
      when :mmr
        request.path_info.match(%r{^/mmr/})
      when :strava
        request.path_info.match(%r{^/strava/})
      else
        false
      end
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

    def first_day_of_month(date)
      DateTime.parse(Date.new(date.year, date.month, 1).strftime(midnight_date_format))
    end

    def midnight_date_format
      "%Y-%m-%dT00:00:00Z"
    end

    def display_in_miles(distance_in_meters)
      "%0.2f miles" % (distance_in_meters.to_f * 0.00062137)
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

    def branch_on_upload_response(upload_response)
      if upload_response.error?
        flash[:error] = upload_response.error
        @redirect = true
        @url = workout_upload_path("error")
      elsif upload_response.duplicate?
        @redirect = true
        @url = workout_upload_path("duplicate")
      elsif upload_response.processing?
        @redirect = false
        @url = workout_upload_path("poll")
      elsif upload_response.created?
        @redirect = true
        @url = workout_upload_path("complete")
      end
      erb :upload_poll, layout: false
    end

  end
end
