class EventsController < ApplicationController
  before_filter :find_or_create_event, only: [:hide, :like, :dislike]

  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'București'
    end
    p '!!!!!!!!!!!!!!!'
    p 'SEARCHING FOR'
    p @search_string
    begin
      # Filter the event based on the keywords defined in Category by the name of the category
      @filter_param = params.require(:filter)

    rescue ActionController::ParameterMissing
      # no category set. Show all the events
      @filter_param = nil
    end

    @events = EventSearch.new(@search_string, current_user, @filter_param).events_ordered_by_like_dislike
  end


  def map

  end

  def hide
    @event.action = 'hide'
    @event.save

    render json: {erors: []}
  end

  def like
    @event.action = 'like'
    @event.save

    add_keywords_score(@event.event_id, 1)

    render json: {erors: []}
  end

  def dislike
    @event.action = 'dislike'
    @event.save

    add_keywords_score(@event.event_id, -1)

    render json: {erors: []}
  end

  private
  def find_or_create_event
    @event = current_user.event_filters.find_or_create_by(event_id: params.require(:event_id))
  end

  def add_keywords_score(event_id, score)
    ev = FbGraph::Event.new(event_id, access_token: current_user.token).fetch

    ev.raw_attributes[:description].split(/\W+/).each do |keyword|
      if keyword.size > 3
        keyword = ActiveSupport::Inflector.transliterate(keyword)
        k = Keyword.find_by_keyword(keyword)
        if k
          k.score = 0 if k.score.nil?
          k.score += score
          k.save
        end
      end
    end
  end
end
