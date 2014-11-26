class EventsController < ApplicationController
  def index
    @events = FbGraph::Event.search('Bucharest', access_token: current_user.token, fields: 'cover,name,description,venue,start_time,picture')
  end
end
