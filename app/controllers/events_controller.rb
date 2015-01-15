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

    render json: {erors: []}
  end

  def dislike
    @event.action = 'dislike'
    @event.save

    render json: {erors: []}
  end

  private
  def find_or_create_event
    @event = current_user.event_filters.find_or_create_by(event_id: params.require(:event_id))
  end
end
