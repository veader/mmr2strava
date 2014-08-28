# test_helper.rb
require "simplecov"
SimpleCov.start

MAIN_DIR=File.expand_path(File.join(File.dirname(__FILE__), ".."))
ENV["MAIN_DIR"]=MAIN_DIR

# add our root and lib dirs to the load path
$:.unshift MAIN_DIR
$:.unshift "#{MAIN_DIR}/lib/"
$:.unshift "#{MAIN_DIR}/lib/models/"
$:.unshift "#{MAIN_DIR}/lib/helpers/"

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "minitest/pride"
require "mocha/setup"
require "rack/test"
require "app"

require "pp"
require "ostruct"

# ActiveRecord::Base.logger.level = 1
# I18n.enforce_available_locales = false

def assert_redirect_to_login
  assert !last_response.ok?
  assert last_response.redirect?
  assert_match "/login", last_response.location
end

# ---------------------------------------------------------------------
def get_request_with_auth(url)
  get url, {}, "rack.session" => auth_session
end

def post_request_with_auth(url)
  post url, {}, "rack.session" => auth_session
end

def auth_session
  assoc_mock = mock
  assoc_mock.expects(:first).returns(AuthUser.new(id: 2))
  AuthUser.expects(:where).with(id: 2).returns(assoc_mock)
  { user_id: 2 } # returned
end
