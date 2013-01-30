class HeartrateJS.Views.Calculating extends Backbone.View

  el: '#container'

  initialize: ->
    @template = _.template $('#tmpl-calculating').text()

  render: ->
    @$el.html @template()
    @


