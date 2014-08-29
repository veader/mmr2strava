require "mmf"

class AuthUser < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, with: /shawn\@veader\.org/, message: "You're not the right person!"

  def self.find_by_omniauth(auth_hash)
    where(email: auth_hash['info']['email']).first
  end

  def self.create_with_omniauth(auth_hash)
    create(email: auth_hash['info']['email'],
           name:  auth_hash['info']['name'],
           uid:   auth_hash['uid'],
           token: auth_hash['credentials']['token'])
  end

  def self.find_or_create_by_omniauth(auth_hash)
    find_by_omniauth(auth_hash) || create_with_omniauth(auth_hash)
  end

  def has_mmr_access?
    !self.mmr_token.blank?
  end

  def has_strava_access?
    !self.strava_token.blank?
  end

  def needs_access_grants?
    !has_mmr_access? || !has_strava_access?
  end

  # ------------------------------------------------------------
  # MapMyFitness
  def mmr_client
    @_mmr_client ||= \
      Mmf::Client.new do |config|
        config.client_key    = ENV["MMF_API_KEY"]
        config.client_secret = ENV["MMF_API_SECRET"]
        config.access_token  = self.mmr_token
      end
  end

  def mmr_user
    @_mmr_user ||= MMR::User.new(self.mmr_client.me)
  end

  def gather_mmr_user_id
    if self.mmr_user_id.blank?
      update_attribute(:mmr_user_id, self.mmr_client.me["id"])
    end
  end

end
