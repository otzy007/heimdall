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
      filter = @user.my_categories.collect {|c| Category.find(c.category_id).keywords }.join(',')  
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

    @filtered_events = []
    @events.map do |e|
      filter = @user.event_filters.find_by_event_id(e.identifier)

      if filter && filter.action == 'like'
        # push the event in the front
        @filtered_events.unshift(e)
      else
        # push it at the end
        @filtered_events << e
      end
    end

    @filtered_events
  end
end
