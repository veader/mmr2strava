require "mmr_client"

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
           token: auth_hash['credentials'['token']])
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

  def mmr_client
    @_mmr_client ||= MMR::Client.new(self.mmr_token)
  end

end
