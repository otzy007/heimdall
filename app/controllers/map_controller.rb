class MapController < ApplicationController
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

    @hash = Gmaps4rails.build_markers(@events) do |event, marker|
      venue = event.venue
      if venue
        marker.lat (event.venue.class == FbGraph::Page)? venue.raw_attributes[:latitude] : venue.latitude
        marker.lng (event.venue.class == FbGraph::Page)? venue.raw_attributes[:longitude] : venue.latitude
        marker.infowindow "<a href='https://facebook.com/#{event.identifier}''>#{event.name}</a>".html_safe
      end
    end
  end
end
