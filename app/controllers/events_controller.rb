class EventsController < ApplicationController
  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'Bucharest'
    end

    @events = FbGraph::Event.search(@search_string, access_token: current_user.token, fields: 'cover,name,description,venue,start_time,picture')
  end

  def name_for_coords(latitude, longitude)
    Gmaps4rails.places(latitude, longitude, 'AIzaSyBuvYB3BBl-wa8F8Y4BqMT_Pn4hsSq_2dc', nil, 20)[0][:name]
  end
end
