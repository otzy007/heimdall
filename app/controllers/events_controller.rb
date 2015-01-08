class EventsController < ApplicationController
  def index
    begin
      latitude = params.require(:latitude)
      longitude = params.require(:longitude)

      @search_string = name_for_coords(latitude, longitude)
    rescue ActionController::ParameterMissing
      @search_string = 'Bucharest'
    end

    @events = FbGraph::Event.search(
        @search_string,
        access_token: current_user.token,
        fields: 'cover,name,description,venue,start_time,picture'
    ).reject do |e|
      EventFilter.exists?(action: "hide", event_id: e.identifier)
    end

    begin
      # Filter the event based on the keywords defined in Category by the name of the category
      filter_param = params.require(:filter)

      #select only the events that containt at least one keyword that defines the category
      @events = @events.select do |e|
          filter = Category.find_by_name(filter_param.capitalize).keywords

          #return true if any of the keywords are found in the description or the name of the event
          res = filter.split(',').any? do |k|
            ActiveSupport::Inflector.transliterate(e.name).include?(k) ||
                ActiveSupport::Inflector.transliterate(e.description.to_s).include?(k)
          end

          e if res
      end

    rescue ActionController::ParameterMissing
      # no category set. Show all the events
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
