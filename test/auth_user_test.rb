require File.join(File.dirname(__FILE__), "test_helper.rb")

describe AuthUser do

  describe "self.find_by_omniauth" do
    it "will look for user by email" do
      oauth_hash = { "info" => { "email" => "shawn@veader.org" } }
      AuthUser.expects(:where).with(email: "shawn@veader.org").returns(["foo"])
      AuthUser.find_by_omniauth(oauth_hash).must_equal "foo"
    end
  end

  describe "self.create_with_omniauth" do
    it "will create user based on contents of oauth hash" do
      email = "shawn@veader.org"
      name  = "Shawn Veader"
      uid   = "12345"
      token = "some_token"
      oauth_hash = { "info" => { "email" => email, "name"  => name },
                     "uid"  => "12345",
                     "credentials" => { "token" => token },
                   }
      AuthUser.expects(:create) \
              .with(email: email, name: name, uid: uid, token: token) \
              .returns(true)
      AuthUser.create_with_omniauth(oauth_hash).must_equal true
    end
  end

  describe "#has_mmr_access?" do
    it "checks if mmr_token is set" do
      user = AuthUser.new
      user.has_mmr_access?.must_equal false
      user.mmr_token = "foo"
      user.has_mmr_access?.must_equal true
    end
  end

  describe "#has_strava_access?" do
    it "checks if strava token is set" do
      user = AuthUser.new
      user.has_strava_access?.must_equal false
      user.strava_token = "foo"
      user.has_strava_access?.must_equal true
    end
  end

  describe "#needs_access_grants?" do
    it "will be true if either token is missing" do
      user = AuthUser.new
      user.mmr_token = "foo"
      user.needs_access_grants?.must_equal true
      user.mmr_token = nil
      user.strava_token = "foo"
      user.needs_access_grants?.must_equal true
    end

    it "will be false if both tokens are set" do
      user = AuthUser.new(mmr_token: "mmr", strava_token: "strava")
      user.needs_access_grants?.must_equal false
    end
  end

  describe "#gather_mmr_user_id" do
    it "will pull id from MMF client request" do
      client_mock = mock
      client_mock.stubs(:me).returns(id: "12345")

      user = AuthUser.new
      user.expects(:mmr_client).returns(client_mock)
      user.expects(:save)

      user.mmr_user_id.must_be_nil
      user.gather_mmr_user_id
    end
  end

end
