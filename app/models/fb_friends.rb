class FBFriends
  def initialize(access_token)
    @me = FbGraph::User.me(access_token).fetch
  end
end
