class EventFilter < ActiveRecord::Base
  ## Event filter actions
  #
  # hide: never show again that event
  # like: preffer events like this one
  # dislike: bring down to the list the event

  belongs_to :user
end
