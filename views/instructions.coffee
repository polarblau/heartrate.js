class HeartrateJS.Views.Instructions extends Backbone.View

  el: '#container'

  initialize: ->
    @template = _.template $('#tmpl-instructions').text()

  render: =>
    @$el.html @template()
    @
