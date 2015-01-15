class EventSearch
  def initialize(search_string, user, filter = nil)
    @filter = filter
    @search_string = search_string
    @user = user
    @token = user.token
  end

  def search
    @events = FbGraph::Event.search(
      @search_string,
      access_token: @token,
      fields: 'cover,name,description,venue,start_time,picture'
    ).reject do |e|
      @user.event_filters.exists?(action: "hide", event_id: e.identifier)
    end

    # Filter the event based on the keywords defined in Category by the name of the category
    if @filter
      filter = Category.find_by_name(@filter.capitalize).keywords
    else
      if @user.my_categories.empty?
        filter = Category.all.collect {|c| c.keywords}.join(',')
      else
        filter = @user.my_categories.collect {|c| Category.find(c.category_id).keywords }.join(',')
      end
    end

    #select only the events that containt at least one keyword that defines the category
    @events = @events.select do |e|
      #return true if any of the keywords are found in the description or the name of the event
      res = filter.split(',').any? do |k|
        ActiveSupport::Inflector.transliterate(e.name).include?(k) ||
        ActiveSupport::Inflector.transliterate(e.description.to_s).include?(k)
      end

      e if res
    end

    @events
  end

  def events_ordered_by_like_dislike
    search

    @filtered_events = @events.zip([0] * @events.size).to_h
    @disliked_events = []

    @events.map do |e|
      EventFilter.where(:event_id => e.identifier).each do |filter|
        if filter.action == 'like'
          # push the event in the front
          @filtered_events[e] += 1
          @filtered_events[e] += 10 if filter.user_id == @user.id
        elsif filter.action == 'dislike'
          @filtered_events[e] -= 1
          @filtered_events[e] -= 10 if filter.user_id == @user.id
        end
      end
    end

    # add friends events at the beginning of the list
    @filtered_events.sort_by {|_,v| v}.reverse.to_h.keys
  end

  def add_friends_events
    FBFriends.new(User.first.token).friends_events.reject do |e|
      @user.event_filters.exists?(action: "hide", event_id: e.identifier)
    end
  end
end
