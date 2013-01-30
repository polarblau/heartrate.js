class HeartrateJS.Views.Measuring extends Backbone.View

  el: '#container'
  events:
    'click a.cancel': '_cancel'

  initialize: (options) ->
    @template = _.template $('#tmpl-measuring').text()

  render: ->
    @$el.html @template()
    @_setupAndStartRecorder()
    @_setupAndStartTimer()
    @

  #

  _cancel: (e) ->
    clearInterval @interval if @interval?

  _setupAndStartRecorder: ->
    @recorder = new HeartrateJS.Utils.Recorder
      duration: HeartrateJS.Settings.measurementDuration
      canvas  : @$el.find 'canvas'
      preview : @$el.find 'video'

    @buffer    = []
    @recorder.on 'capture', (data) =>
      @buffer.push data
      # @collection.add new HeartrateJS.Models.DataPoint(data)

  _setupAndStartTimer: ->
    @start     = (new Date).getTime()
    @interval  = setInterval @_tick, 50
    @$progress = @$el.find '.progress .progress-bar'
    @measure   = HeartrateJS.Settings.measurementDuration
    @wait      = HeartrateJS.Settings.waitingDuration
    @duration  = @wait + @measure
    threshold  = @wait / @duration * 100

    @$progress.parent().find('.threshold').css
      width: "#{threshold}%"

  _tick: =>
    now        = (new Date).getTime()
    diff       = now - @start
    percentage = Math.round diff / @duration * 100

    if diff >= @wait and not @recorder.isStarted()
      @recorder.start()
      @$progress.removeClass 'waiting'

    if diff >= @duration
      @recorder.stop()
      @trigger 'complete'
      _.forEach @buffer, (data) =>
        @collection.add new HeartrateJS.Models.DataPoint(data)
      clearInterval @interval

    @$progress.css 'width', "#{percentage}%"
