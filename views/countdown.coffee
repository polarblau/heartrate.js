class HeartrateJS.Views.Countdown extends Backbone.View

  el: '#container'

  initialize: ->
    @template = _.template $('#tmpl-countdown').text()

  render: ->
    @$el.html @template()
    @_setupCountdown()
    @

  #

  _setupCountdown: ->
    @start    = (new Date).getTime()
    @interval = setInterval @_count, 50
    @$counter = @$el.find '#counter'

  _count: =>
    now       = (new Date).getTime()
    diff      = now - @start
    duration  = HeartrateJS.Settings.countdownDuration

    @$counter.text Math.round (duration - diff) / 1000

    if diff >= duration
      @trigger 'complete'
      clearInterval @interval
