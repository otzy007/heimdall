class FBFriends
  def initialize(access_token)
    @me = FbGraph::User.me(access_token).fetch
  end

  def friends
    @me.friends
  end

  def friends_events
    @me.friends.collect { |f| f.events }.flatten
  end
end
