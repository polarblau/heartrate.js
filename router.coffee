class HeartrateJS.Router extends Backbone.Router

  routes:
    ''         : 'index'
    'measure'  : 'measure'
    'calculate': 'calculate'
    'result'   : 'result'

  measurement: null

  # Instructions
  index: ->
    new HeartrateJS.Views.Instructions().render()


  # Take actual measurement
  measure: ->
    @measurement = new HeartrateJS.Collections.Measurement()
    measuring    = new HeartrateJS.Views.Measuring(collection: @measurement).render()
    measuring.on 'complete', =>
      window.location.hash = 'calculate'


  # Calculate heart rate
  calculate: ->
    if @measurement?
      @measurement.calculate()
      @measurement.on 'calculated', ->
        window.location.hash = 'result'
      new HeartrateJS.Views.Calculating().render()
    else
      window.location.hash = ''


  # Display result of measurement
  result: ->
    if @measurement?
      new HeartrateJS.Views.Result(collection: @measurement).render()
    else
      window.location.hash = ''

