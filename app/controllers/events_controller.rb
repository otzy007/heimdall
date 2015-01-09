class EventsController < ApplicationController
  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'Bucharest'
    end

    begin
      # Filter the event based on the keywords defined in Category by the name of the category
      @filter_param = params.require(:filter)

    rescue ActionController::ParameterMissing
      # no category set. Show all the events
      @filter_param = nil
    end

    @events = EventSearch.new(@search_string, current_user, @filter_param).search
  end


  def map

  end

  def hide
    current_user.event_filters.create(event_id: params.require(:event_id), action: 'hide')

    render json: {erors: []}
  end

  def like
    current_user.event_filters.create(event_id: params.require(:event_id), action: 'like')

    render json: {erors: []}
  end

  def dislike
    current_user.event_filters.create(event_id: params.require(:event_id), action: 'dislike')

    render json: {erors: []}
  end

  private
  def name_for_coords(latitude, longitude)
    Gmaps4rails.places(latitude, longitude, 'AIzaSyBuvYB3BBl-wa8F8Y4BqMT_Pn4hsSq_2dc', nil, 200)[0][:name]
  end
end
