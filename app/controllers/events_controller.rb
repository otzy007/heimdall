class EventsController < ApplicationController
  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)
      filter = params.require('filter')

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'Bucharest'
    end
    p @search_string
    p filter
    p params
    @events = FbGraph::Event.search(
        @search_string,
        access_token: current_user.token,
        fields: 'cover,name,description,venue,start_time,picture'
    ).reject do |e|
      EventFilter.exists?(action: "hide", event_id: e.identifier)
    end

    if filter && filter.key?(:filter)
      @events.collect do |e|
          filter = Filter.find_by_name(filter[:filter])
          filter.split(',').any? do |k|
            p k
            ActiveSupport::Inflector.transliterate(name.includes?(k)) || ActiveSupport::Inflector.transliterate(description.includes?(k))
          end
        end
    end
  end


  def map

  end

  def hide
    EventFilter.create(event_id: params.require(:event_id), action: 'hide')

    render json: {erors: []}
  end

  def like
    EventFilter.create(event_id: params.require(:event_id), action: 'like')

    render json: {erors: []}
  end

  def dislike
    EventFilter.create(event_id: params.require(:event_id), action: 'dislike')

    render json: {erors: []}
  end

  private
  def name_for_coords(latitude, longitude)
    Gmaps4rails.places(latitude, longitude, 'AIzaSyBuvYB3BBl-wa8F8Y4BqMT_Pn4hsSq_2dc', nil, 200)[0][:name]
  end
end
