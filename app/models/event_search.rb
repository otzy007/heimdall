class EventSearch
  def initialize(search_string, user, filter = nil)
    @filter = filter
    @search_string = search_string
    @user = user
    @token = user.token
  end

  def search
    @events = Rails.cache.read('events') || FbGraph::Event.search(
      @search_string,
      access_token: @token,
      fields: 'cover,name,description,venue,start_time,picture',
      location: @search_string,
      start_time: Date.today + 1
    ).reject do |e|
      @user.event_filters.exists?(action: "hide", event_id: e.identifier)
    end

    Rails.cache.write('events', @events)

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

    #select only the events that contain at least one keyword that defines the category
    @events = @events.select do |e|
      description = Rails.cache.read("descr#{e.identifier}") || e.description.to_s

      Rails.cache.write("descr#{e.identifier}", description)
      #return true if any of the keywords are found in the description or the name of the event
      res = filter.split(',').any? do |k|
        ActiveSupport::Inflector.transliterate(e.name).include?(k) ||
        ActiveSupport::Inflector.transliterate(description).include?(k)
      end


      # categs = if @user.my_categories.empty?
      #   Category.all
      # else
      #   @user.my_categories.collect {|c| Category.find(c.category_id)}
      # end
      # categs_score = categs.zip([0] * categs.size).to_h

      # categs.map do |c|
      #   c.keywords.split(',').map do |keyword|
      #     p keyword
      #     # p e.description.to_s
      #     if ActiveSupport::Inflector.transliterate(e.description.to_s).include?(keyword)
      #       if Keyword.find_by_keyword(keyword)
      #         categs_score[c] += Keyword.find_by_keyword(keyword).score
      #         # break
      #       end
      #     end
      #   end
      # end
      #
      # dcat = categs_score.sort_by {|_,v| v}.last
      # # p categs_score.sort_by {|_,v| v}
      # p 'TE DOMIN'
      # if dcat[1] > 0
      #   e.define_singleton_method(:category) { dcat[0].name }
      # end
      e if res
    end

    @events
  end

  def events_ordered_by_like_dislike
    search

    # @filtered_events = @events.zip([0] * @events.size).to_h
    @filtered_events = order_by_keywords
    @disliked_events = []

    @filtered_events.map do |e, _|
      EventFilter.where(:event_id => e.identifier).map do |filter|
        if filter.action == 'like'
          # push the event in the front
          @filtered_events[e] += 1
          @filtered_events[e] += 2 if filter.user_id == @user.id
        elsif filter.action == 'dislike'
          @filtered_events[e] -= 1
          @filtered_events[e] -= 2 if filter.user_id == @user.id
        end
      end
    end

    # add friends events at the beginning of the list
    @filtered_events.merge(add_friends_events) {|_, oldval, newval| oldval + newval}.sort_by {|_,v| v}.reverse.to_h.keys
  end

  def add_friends_events
    events = FBFriends.new(User.first.token).friends_events.reject do |e|
      @user.event_filters.exists?(action: "hide", event_id: e.identifier)
    end

    events.zip([5] * events.size).to_h
  end

  def order_by_keywords
    @filtered_events = @events.zip([0] * @events.size).to_h

    keywords = Keyword.all
    @events.map do |e|
      description = Rails.cache.read(e.identifier.to_s) || e.raw_attributes[:description]
      Rails.cache.write(e.identifier.to_s, description)
      if description
        keywords.map do |k|
          if description.downcase.split(/\W+/).include?(k.keyword)
              @filtered_events[e] += k.score
          end
        end
        # e.raw_attributes[:description].split(/\W+/).map do |word|
        #   keyword_score = Keyword.where(keyword: ActiveSupport::Inflector.transliterate(word)).sum(:score)
        #   my_keyword = @user.keywords.find_by_keyword(word)
        #
        # # unless keyword.nil? && keyword.empty?
        #   @filtered_events[e] += keyword_score
        #   # @filtered_events[e] += keyword_score * 10 if my_keyword
        # # end
        # end
      end
    end

    @filtered_events
  end
end
