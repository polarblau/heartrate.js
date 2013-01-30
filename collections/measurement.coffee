class HeartrateJS.Collections.Measurement extends Backbone.Collection

  model: HeartrateJS.Models.DataPoint

  initialize: (options) ->
    @set = new Orange.JobSet
    @set.on 'complete', =>
      @trigger 'calculated'

    @on 'add', @_enqueueDataPoint
    @on 'change', -> @_peaks = null

  calculate: ->
    @set.perform()

  toNumber: ->
    meanDurationMin = @_averageDistance @peaks('min')
    meanDurationMax = @_averageDistance @peaks('max')

    60000 / ((meanDurationMin + meanDurationMax) / 2)

  toHighchartsSeries: (name) ->
    data = @map (model) -> [model.get('timestamp'), model.get('intensity')]
    { name: name, data: data }

  peaks: (method = 'min', repetitions = 5, span = 5, isRepitition = false) ->
    # returned memoized version if possible
    # return @_peaks[method] if !isRepitition and @_peaks? and @_peaks[method]?

    # store
    [@_peaks, peaking] = [{}, []]

    # looking for min or max peaks?
    compare = (a, b) -> if method is 'min' then a < b else a > b

    @models.forEach (m, i) =>
      section = @models.slice(i, span + i)
      peak    = _.first(section)
      section.forEach (model, j) ->
        peak  = model if compare(model.get('intensity'), peak.get('intensity'))
      peaking.push peak

    # return new collection only containing peaking models
    @_peaks[method] = new HeartrateJS.Collections.Measurement(peaking)

    # run method recursively as defined in `repetitions`
    if repetitions > 1
      @_peaks[method] = @_peaks[method].peaks method, --repetitions, span, true

    @_peaks[method]

  #

  # calculate the average distance between all models' timestamps
  _averageDistance: (peaks) ->
    sumDuration = 0
    peaks.forEach (model, i) =>
      timestamp = model.get('timestamp')

      unless i == peaks.length - 1
        nextTimestamp = peaks.at(i + 1).get('timestamp')
        sumDuration  += (nextTimestamp - timestamp)

    sumDuration / (peaks.length - 1)

  _enqueueDataPoint: (dataPoint) =>
    @set.push dataPoint.enqueue()
