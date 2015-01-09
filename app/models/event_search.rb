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
      #select only the events that containt at least one keyword that defines the category
      @events = @events.select do |e|
        filter = Category.find_by_name(@filter.capitalize).keywords

        #return true if any of the keywords are found in the description or the name of the event
        res = filter.split(',').any? do |k|
          ActiveSupport::Inflector.transliterate(e.name).include?(k) ||
          ActiveSupport::Inflector.transliterate(e.description.to_s).include?(k)
        end

        e if res
      end
    end

    @events
  end
end
