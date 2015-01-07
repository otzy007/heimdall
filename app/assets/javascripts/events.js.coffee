# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Application ||= {}


Application.hide_event = (event_id) ->
  request = $.get 'events/' + event_id + '/hide'
  request.success (data) -> $('#'+event_id.toString()).remove()

Application.like_event = (event_id) ->
  request = $.get 'events/' + event_id + '/like'

Application.dislike_event = (event_id) ->
  request = $.get 'events/' + event_id + '/dislike'