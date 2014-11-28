class EventsController < ApplicationController
  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'Bucharest'
    end
    p @search_string
    @events = FbGraph::Event.search(
        @search_string,
        access_token: current_user.token,
        fields: 'cover,name,description,venue,start_time,picture'
    ).reject do |e|
      EventFilter.exists?(action: "hide", event_id: e.identifier)
    end
  end


  def map

  end

  def hide
    EventFilter.create(event_id: params.require(:event_id), action: 'hide')

    render json: {erors: []}
  end

  private
  def name_for_coords(latitude, longitude)
    Gmaps4rails.places(latitude, longitude, 'AIzaSyBuvYB3BBl-wa8F8Y4BqMT_Pn4hsSq_2dc', nil, 200)[0][:name]
  end
end
