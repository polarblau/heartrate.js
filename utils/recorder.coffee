class HeartrateJS.Utils.Recorder

  settings:
    duration: 20000
    width   : 640
    height  : 480

  localMediaStream: null

  constructor: (options) ->
    _.extend @, Backbone.Events
    @settings = _.extend @settings, options

    @ctx      = $(@settings.canvas).get(0).getContext('2d')
    @preview  = $(@settings.preview).get(0)

    @init()

  init: ->
    success = (stream) =>
      # setup preview
      @preview.src      = window.URL.createObjectURL(stream)
      @localMediaStream = stream

      @preview.addEventListener 'loadeddata', (e) =>
        # when data incoming, start capturing
        @_capture()
        @trigger 'start'
    error = ->
      console.error arguments
    navigator.getUserMedia video: true, success, error

  start: ->
    @start   = (new Date).getTime()
    @started = true

  isStarted: ->
    @started? and @started

  stop: ->
    @started = false

  isStopped: ->
    @started == false

  #

  _capture: =>
    @ctx.drawImage(@preview, 0, 0) if @localMediaStream?

    if @isStarted()

      now       = (new Date).getTime()
      pixels    = @ctx.getImageData(0, 0, @settings.width, @settings.height).data
      timestamp = now - @start

      @trigger 'capture', { pixels: pixels, timestamp: timestamp }

    requestAnimationFrame @_capture unless @isStopped()
