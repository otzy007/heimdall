# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.Application ||= {}

Application.checked = (category) ->
  if $('#' + category).prop('checked') == false
    request = $.ajax 'categories/' + category, type: 'DELETE'
  else
    request = $.post 'categories/', {name: category}
